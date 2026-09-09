import XCTest

/// Drives the app through the screens that become App Store screenshots and attaches each one to the
/// result bundle, where the shared `screenshots` runner collects them.
///
/// One test rather than one per screen: the shots are a walk through a single launch, and splitting
/// them would pay the launch — and the reseed — every time.
/// Two of the eight screens are missing from the Mac set: the sprite detail and the cutter sheet.
/// Both are reached by clicking, and on Mac Catalyst a synthesized click is inert — the pointer
/// moves onto the row, the click is delivered, and nothing happens, however many times it is
/// repeated and whichever of the element, its cell, or its coordinate it is aimed at. The sidebar
/// is steered with the arrow keys instead, which do work, and the two screens with no keyboard
/// route are left out of that platform's set rather than faked.
@MainActor
final class ScreenshotTests: XCTestCase {

    private var app: XCUIApplication!

    func testCaptureAppStoreScreenshots() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()

        // The app opens on Browse — the sidebar selects it by default, and a compact width has
        // already pushed it — so the first shot needs no tap. Wait on "Sci-Fi": Featured leads with
        // a seasonal collection until the seed removes it, so its presence means seeding is done.
        bringToFront()
        let featured = control("Sci-Fi")
        XCTAssertTrue(featured.waitForExistence(timeout: 60), "seeded content never appeared\n\(app.debugDescription)")
        settle()
        capture("01-browse")

        open("People & Animals")
        capture("02-category")

        open("Fonts")
        capture("03-fonts")

        open("Palettes")
        capture("04-palettes")

        open("My Collection")
        capture("07-my-collection")

        open("My Palettes")
        capture("05-my-palettes")

        // The cutter is a sheet off the sidebar's toolbar, not a screen the sidebar selects.
        #if !targetEnvironment(macCatalyst)
        showSidebar()
        activate(control("Cut Sprites"), "the cut sprites button",
                 until: { self.control("Cancel").exists })
        settle()
        capture("06-cutter")
        activate(control("Cancel"), "the cutter's cancel button")
        settle()
        #endif

        // Last on purpose: pushing a sprite detail leaves it on top of the detail stack, and on a
        // regular-width layout a later sidebar tap would swap the screen behind it rather than
        // replacing it.
        #if !targetEnvironment(macCatalyst)
        // 32x32, so it holds up blown up.
        activate(control("Sprite.0zbdd3"), "the genie sprite")
        settle()
        capture("08-sprite")
        #endif
    }

    // MARK: - Driving

    /// Selects a screen from the sidebar and waits for it to settle.
    ///
    /// The screen is open once the window says so: a Catalyst window takes its title from the
    /// detail's navigation title, which is the row's own name.
    private func open(_ row: String) {
        #if targetEnvironment(macCatalyst)
        selectWithKeyboard(row)
        settle()
        return
        #else
        showSidebar()
        activate(sidebarRow(row), "the \(row) row",
                 alternates: [enclosingCell(labelled: row)],
                 until: { self.windowTitle() == row })
        settle()
        #endif
    }

    #if targetEnvironment(macCatalyst)
    /// The sidebar's rows, top to bottom, so a keyboard walk knows which way to go.
    private static let sidebarOrder = [
        "Browse", "People & Animals", "Food", "Weapons & Tools", "Clothing", "Treasure",
        "Misc. Items", "Nature", "Objects", "Effects", "Interface", "Tiles", "Artwork",
        "Fonts", "Palettes", "My Collection", "My Palettes", "iMessage Stickers", "Imports",
    ]

    /// Walks the sidebar's selection to `row` with the arrow keys.
    ///
    /// Clicks are inert here: the pointer moves onto the row, the click is delivered, and the
    /// selection does not move — six in a row change nothing. The sidebar is keyboard focused from
    /// launch, though, and arrow keys drive its selection, so the walk steers with those and reads
    /// the window title back to know where it landed.
    ///
    /// It steps toward the target rather than scanning: overshooting reaches Imports, which sits on
    /// a spinner forever (iCloud's metadata query is stubbed out on Catalyst) and has no title to
    /// steer back from.
    private func selectWithKeyboard(_ row: String) {
        guard let target = Self.sidebarOrder.firstIndex(of: row) else {
            return XCTFail("\(row) is not a sidebar row")
        }
        for _ in 0 ..< 30 {
            guard let title = windowTitle(), let current = Self.sidebarOrder.firstIndex(of: title) else {
                return XCTFail("the sidebar is showing \(windowTitle() ?? "nothing"), which is not a row")
            }
            if current == target { return }
            let key: XCUIKeyboardKey = current < target ? .downArrow : .upArrow
            app.typeText(key.rawValue)
            Thread.sleep(forTimeInterval: 0.4)
        }
        XCTFail("could not steer the sidebar to \(row); it is showing \(windowTitle() ?? "nothing")")
    }
    #endif

    /// The Mac window's title, read out of the element tree — `XCUIElement.title` is macOS-only, and
    /// a Catalyst test compiles against the iOS SDK. `nil` anywhere else.
    private func windowTitle() -> String? {
        #if targetEnvironment(macCatalyst)
        guard let line = app.debugDescription
            .split(separator: "\n")
            .first(where: { $0.contains("identifier: 'SceneWindow'") }),
              let range = line.range(of: "title: '") else { return nil }
        let rest = line[range.upperBound...]
        guard let end = rest.firstIndex(of: "'") else { return nil }
        return String(rest[..<end])
        #else
        return nil
        #endif
    }

    /// Brings the sidebar back on screen by popping whatever is stacked on top of it.
    ///
    /// A compact width collapses the split view onto a stack, so the sidebar is reachable only by
    /// popping back to it; at a regular width — iPad, the Mac, Vision — there is nothing to pop and
    /// this returns immediately. Deliberately *not* written as "is some sidebar row on screen?":
    /// that question cannot be asked without scrolling to look, and scrolling the sidebar to answer
    /// it is what destroyed the rows the walk was about to tap.
    private func showSidebar() {
        for _ in 0 ..< 4 {
            let backButtons = app.navigationBars.buttons.matching(identifier: "BackButton")
            guard backButtons.count > 0 else { return }
            let back = backButtons.element(boundBy: 0)
            guard back.isHittable else { return }
            back.tap()
            settle(seconds: 1)
        }
    }

    /// A sidebar row, scrolling the sidebar until it exists.
    ///
    /// The sidebar is a lazy collection view: a row below the fold has not been built yet, and one
    /// scrolled *past* stops existing again — so a row missed by a first look can be in either
    /// direction. Rewind to the top, then walk down.
    private func sidebarRow(_ label: String) -> XCUIElement {
        var row = control(label)
        if row.exists { return row }

        var sidebar = app.collectionViews["Sidebar"]
        if !sidebar.exists { sidebar = app.collectionViews.element(boundBy: 0) }
        guard sidebar.exists else { return row }

        for _ in 0 ..< 6 { sidebar.swipeDown() }
        row = control(label)
        if row.exists { return row }

        for _ in 0 ..< 6 {
            sidebar.swipeUp()
            row = control(label)
            if row.exists { return row }
        }
        return row
    }

    /// Matches by accessibility identifier or label, across the element types a control can surface
    /// as: a sidebar row is a cell, a toolbar item is a button, and a segment can be a radio button.
    ///
    /// Resolved with `element(boundBy: 0)` rather than `firstMatch`, which can report `exists ==
    /// false` for a query that plainly matches.
    private func control(_ name: String) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier == %@ OR label == %@", name, name)
        // Buttons first: a `List` row surfaces as a cell *containing* a button, and on Mac Catalyst
        // the cell carries the row's label too — but clicking the cell does not select the row, so a
        // cell match would silently do nothing.
        for query in [app.buttons, app.cells, app.radioButtons, app.descendants(matching: .tab)] {
            let matches = query.matching(predicate)
            if matches.count > 0 { return matches.element(boundBy: 0) }
        }
        return app.cells[name]   // nothing matched; let the caller's assertion name the miss
    }

    /// Clicks or taps an element, retrying on the Mac until it has visibly taken effect.
    ///
    /// A click on a Catalyst window that is not key is spent activating the window rather than
    /// hitting what is under the pointer, so the first one routinely does nothing — XCTest says as
    /// much when it fails ("a retry-loop around the event may resolve the issue"). `until` is how
    /// this can tell the difference between a click that landed and one that was swallowed.
    /// The `List` cell wrapping a row, which on Mac Catalyst is what a click has to land on — the
    /// button inside it takes the click and does nothing with it.
    private func enclosingCell(labelled label: String) -> XCUIElement {
        app.cells.containing(NSPredicate(format: "label == %@ OR identifier == %@", label, label))
            .element(boundBy: 0)
    }

    private func activate(_ element: XCUIElement, _ description: String,
                          alternates: [XCUIElement] = [], until succeeded: (() -> Bool)? = nil) {
        XCTAssertTrue(element.waitForExistence(timeout: 15), "never found \(description)\n\(app.debugDescription)")
        bringToFront()

        #if targetEnvironment(macCatalyst)
        if let succeeded {
            // Alternating between the row's button and its cell: which of the two a Catalyst click
            // has to hit is not something the tree tells you, so try both rather than guess.
            let elements = ([element] + alternates).filter(\.exists)
            // Both spellings of a click, because on this SDK the plain one is often inert: a hit on
            // the element, and a hit on the point it occupies.
            let candidates: [() -> Void] = elements.flatMap { element in
                [{ element.tap() },
                 { element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }]
            }
            for attempt in 1 ... 6 {
                candidates[(attempt - 1) % candidates.count]()
                for _ in 0 ..< 10 {
                    Thread.sleep(forTimeInterval: 0.2)
                    if succeeded() { return }
                }
                if attempt == 6 {
                    XCTFail("clicked \(description) six times and nothing happened\n\(app.debugDescription)")
                }
            }
            return
        }
        #endif
        #if os(macOS)
        element.click()
        #else
        // Mac Catalyst builds against the iOS SDK, where `click()` does not exist — `tap()` is the
        // Catalyst spelling of the same thing.
        element.tap()
        #endif
    }

    /// Makes the app's window key before clicking it.
    ///
    /// A Mac window that is not frontmost comes back `Disabled` in the element tree and swallows
    /// every click — the walk then photographs the same screen eight times, having navigated
    /// nowhere. Nothing steals focus on a simulator, so this is a Mac-only concern.
    private func bringToFront() {
        #if os(macOS)
        app.activate()
        #endif
    }

    /// Animations and async content have no element to wait on, so the shots pause instead. Sprite
    /// detail animates its frames on a timer and asks Apple Intelligence for related sprites, so it
    /// gets the same pause as everything else and is simply photographed mid-animation.
    private func settle(seconds: TimeInterval = 2) {
        Thread.sleep(forTimeInterval: seconds)
    }

    // MARK: - Capturing

    private func capture(_ name: String) {
        // Every capture below photographs the whole screen, or the frontmost window — never this
        // app in particular. So an app that has lost the foreground yields another app's UI, filed
        // under this app's name, at the right size, with nothing to notice. The shared runner holds
        // a machine-wide lock so that cannot happen; this is the check that it held.
        XCTAssertEqual(app.state, .runningForeground,
                       "\(name): the app under test was not frontmost — another app has this device")
        #if os(macOS) || targetEnvironment(macCatalyst) || os(visionOS)
        // Both of these are photographed from outside the test: the Mac because only the shell has
        // Screen Recording, visionOS because it has no screen for `XCUIScreen` to return (the call
        // comes back 1x1) and its window alone is neither the store's size nor its framing.
        if requestHostCapture(named: name) { return }
        #if os(visionOS)
        // The handshake directory was unreachable — better a window at the wrong size than no shot.
        attach(XCTAttachment(screenshot: app.screenshot()), named: name)
        #endif
        #else
        // The simulator's screen already *is* the store's canvas, at the exact required pixel size.
        attach(XCTAttachment(screenshot: XCUIScreen.main.screenshot()), named: name)
        #endif
    }

    private func attach(_ attachment: XCTAttachment, named name: String) {
        attachment.name = name
        attachment.lifetime = .keepAlways   // attachments on a passing test are discarded otherwise
        add(attachment)
    }

    #if os(macOS) || targetEnvironment(macCatalyst) || os(visionOS)

    /// Asks the shell running the tests to take the picture, and waits for it.
    ///
    /// The good capture is `screencapture -l`, which reads the window's own buffer: correctly masked
    /// to the rounded corners, with real alpha and the system's own shadow. (`XCUIElement.screenshot()`
    /// crops the *screen* to the window's frame, so it loses the shadow — drawn outside that frame —
    /// and leaves desktop inside the corners.) But `screencapture` needs Screen Recording, which the
    /// test runner has no grant for and the terminal running the script does. So the test drives the
    /// UI and the script takes the picture.
    ///
    /// They meet in a plain directory under /tmp, which works only because the runner is deliberately
    /// unsandboxed (UITests.entitlements): the app is sandboxed and the runner inherits that, and a
    /// sandboxed runner cannot write /tmp while its own container is unreadable to the script.
    /// (On the visionOS simulator the same path is the host's, which is what lets `simctl` answer.)
    private static let handshakeDirectory = URL(fileURLWithPath: "/tmp/app-store-screenshots")

    /// Returns whether the shot was taken. `false` means the handshake directory was unreachable, so
    /// the caller should fall back to whatever it can capture from in here.
    @discardableResult
    private func requestHostCapture(named name: String) -> Bool {
        requestHostAction(named: "request-\(name)", done: "done-\(name)", describedAs: "capture \(name)")
    }

    /// Asks for something other than a shot — activating the app — and waits for the answer.
    @discardableResult
    private func requestHostAction(named name: String) -> Bool {
        requestHostAction(named: name, done: "done-\(name)", describedAs: name)
    }

    @discardableResult
    private func requestHostAction(named requestName: String, done doneName: String, describedAs description: String) -> Bool {
        let files = FileManager.default
        let handshake = Self.handshakeDirectory
        let done = handshake.appendingPathComponent(doneName)
        try? files.removeItem(at: done)

        let request = handshake.appendingPathComponent(requestName)
        guard files.createFile(atPath: request.path, contents: nil) else { return false }

        let deadline = Date().addingTimeInterval(30)
        while Date() < deadline {
            if files.fileExists(atPath: done.path) { return true }
            Thread.sleep(forTimeInterval: 0.1)
        }
        XCTFail("timed out waiting for the script to \(description) — is the runner watching \(handshake.path)?")
        return true   // the runner is the one at fault; a fallback shot would only hide that
    }

    #endif
}
