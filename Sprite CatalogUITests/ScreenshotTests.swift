import XCTest
#if canImport(UIKit)
import UIKit
#endif

/// Drives the app through the screens that become App Store screenshots and attaches each one to the
/// result bundle, where the shared `screenshots` runner collects them.
///
/// One test rather than one per screen: the shots are a walk through a single launch, and splitting
/// them would pay the launch — and the reseed — every time.
///
/// Every platform now walks the same seven screens. It did not always: on Mac Catalyst a
/// synthesized click was inert — the pointer moved onto the row, the click was delivered, and
/// nothing happened — so that build steered the sidebar with the arrow keys and skipped the two
/// screens with no keyboard route. The Mac build is native now and clicks land, so the keyboard
/// walk and the skipped shots are both gone.
///
/// The shots are named in the order the store lists them, which is the order they are taken in.
/// Two screens the walk passes through are deliberately not photographed: Browse, whose value is
/// hard to read at thumbnail size, and the fonts grid, which the font *detail* sells better.
@MainActor
final class ScreenshotTests: XCTestCase {

    private var app: XCUIApplication!

    /// Whether the walk turned the device on its side, which the capture has to undo.
    ///
    /// Tracked here rather than read back from `XCUIDevice.shared.orientation`, which a simulator
    /// answers as portrait however the UI is laid out.
    private var isLandscape = false

    func testCaptureAppStoreScreenshots() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()

        // The app opens on Browse, which is no longer a shot but is still where seeding shows. Wait
        // on "Sci-Fi": Featured leads with a seasonal collection until the seed removes it, so its
        // presence means the demo state is in place and the walk can start.
        bringToFront()
        #if os(macOS)
        openWindowIfNeeded()
        #elseif os(iOS)
        turnToRequestedOrientation()
        #endif
        checkSeedIsThrowaway()
        waitFor(control("Sci-Fi"), "the seeded Sci-Fi featured collection", timeout: 60)
        settle()

        open("Food")
        capture("01-food")

        open("Tiles")
        capture("02-tiles")

        // The font detail rather than the grid: a family blown up to its whole alphabet is what
        // sells the fonts, where the grid is sixty tiles all reading "Aa". Alkhemikal is third in
        // that grid, so it is on screen without scrolling — the grid is lazy, and a cell below the
        // fold is not built to be tapped.
        open("Fonts")
        activate(control("Font.Alkhemikal"), "the Alkhemikal font",
                 until: { self.windowTitle() != "Fonts" })
        settle()
        capture("03-font")

        open("Palettes")
        capture("04-palettes")

        open("My Collection")
        capture("05-my-collection")

        // The cutter is a sheet off the sidebar's toolbar, not a screen the sidebar selects, so
        // what sits behind it is whatever the walk last opened. Artwork, because its cells are the
        // catalog's large pieces and read as artwork even in the strip a sheet leaves showing. On a
        // compact width the sidebar has to come back to reach the button, so the iPhone shot has
        // the sidebar behind it instead.
        open("Artwork")
        showSidebar()
        activate(control("Cut Sprites"), "the cut sprites button",
                 until: { self.control("Cancel").exists })
        settle()
        capture("06-cutter")
        activate(control("Cancel"), "the cutter's cancel button",
                 until: { !self.control("Cancel").exists })
        settle()

        // Last on purpose: pushing a sprite detail leaves it on top of the detail stack, and on a
        // regular-width layout a later sidebar tap would swap the screen behind it rather than
        // replacing it.
        //
        // Treasure, not the Artwork the cutter was over: the shot is of hippo's diamond, which is
        // thirteenth in that grid and so on screen without scrolling — the grid is lazy, and a row
        // below the fold is not built to be tapped.
        open("Treasure")
        activate(control("Sprite.7qop1k"), "hippo's diamond sprite",
                 until: { self.windowTitle() != "Treasure" })
        settle()
        capture("07-sprite")
    }

    // MARK: - The seed

    /// What the app said it seeded, read out of the accessibility tree.
    ///
    /// The app hangs `ScreenshotMode.status` on its root view (`.screenshotModeStatus()`). A walk
    /// that cannot find it is running against a build that has not adopted that modifier, which is
    /// worth saying plainly rather than reporting as an empty seed.
    private var seedStatus: String {
        let label = app.descendants(matching: .any)["ScreenshotMode.Status"]
        guard label.waitForExistence(timeout: 30) else {
            return "no ScreenshotMode.Status element — add .screenshotModeStatus() to the app's root view"
        }
        // A SwiftUI `Text` reaches XCUITest as the element's *value* on macOS and as its *label* on
        // iOS, so take whichever is filled in rather than betting on one.
        if let value = label.value as? String, !value.isEmpty { return value }
        return label.label
    }

    /// Stops the walk when the app did not seed the throwaway state.
    ///
    /// `ScreenshotMode.activate` reports what it seeded, or why it refused. Reading that before the
    /// walk's first wait means a failure to seed shows up as its own reason, rather than as a
    /// missing "Sci-Fi" row that says nothing about why.
    private func checkSeedIsThrowaway() {
        let status = seedStatus
        print("SCREENSHOT MODE: \(status)")
        guard status.hasPrefix("ready") else {
            attach(XCTAttachment(string: app.debugDescription), named: "element-tree")
            return XCTFail("the app did not seed a throwaway state, so there is nothing to photograph — \(status)")
        }
    }

    private static var platform: String {
        #if os(macOS)
        "macOS"
        #elseif os(visionOS)
        "visionOS"
        #else
        UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
        #endif
    }

    /// Which simulator this was, for a failure read days after the run's own log is gone.
    private static var device: String {
        ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "this machine"
    }

    // MARK: - Driving

    /// Waits for `element`, naming the platform, device, and what the seed reported on any miss —
    /// the three things a bare `waitForExistence` failure leaves you to guess at.
    @discardableResult
    private func waitFor(_ element: XCUIElement, _ description: String, timeout: TimeInterval = 15) -> Bool {
        guard !element.waitForExistence(timeout: timeout) else { return true }
        attach(XCTAttachment(string: app.debugDescription), named: "element-tree")
        XCTFail("""
            never found \(description) in \(Int(timeout))s on \(Self.platform), \(Self.device).
            The app reported: \(seedStatus)
            """)
        return false
    }

    /// Selects a screen from the sidebar and waits for it to settle.
    ///
    /// The screen is open once the window says so: a Mac window takes its title from the detail's
    /// navigation title, which is the row's own name. Off the Mac there is no window title to read
    /// and nothing swallows a tap, so the tap is taken at its word.
    private func open(_ row: String) {
        showSidebar()
        activate(sidebarRow(row), "the \(row) row",
                 alternates: [enclosingCell(labelled: row)],
                 until: { self.windowTitle() == row })
        settle()
    }

    /// The Mac window's title. `nil` anywhere else — `XCUIElement.title` is macOS-only.
    ///
    /// Read from the first window rather than a named one: the app has a single titled window open
    /// for the whole walk, and its title is the detail column's navigation title.
    private func windowTitle() -> String? {
        #if os(macOS)
        let window = app.windows.element(boundBy: 0)
        guard window.exists else { return nil }
        return window.title
        #else
        return nil
        #endif
    }

    #if os(macOS)
    /// Opens a window when the launch came up without one.
    ///
    /// `XCUIApplication.launch()` launches a Mac app in the *background*, and AppKit gives a
    /// background launch no window — it holds it until the user arrives. `activate()` is not what
    /// it waits for: only a reopen, the event a Dock icon click sends, builds the window, and a
    /// test runner has no way to send one. So the walk asks for the window itself, with the app's
    /// own New Window.
    ///
    /// Whether a launch gets away without this depends on who started the run: LaunchServices
    /// activates a launched app only while the process that launched it is frontmost, so the same
    /// walk comes up with a window when it is run by hand from a frontmost Terminal and with
    /// nothing but a menu bar when an agent runs it in the background.
    ///
    /// Waiting first rather than counting windows straight after `launch()`, which returns on idle
    /// and can beat the window into the accessibility tree — ⌘N would then open a second, empty
    /// one and the walk would photograph that.
    private func openWindowIfNeeded() {
        if app.windows.firstMatch.waitForExistence(timeout: 10) { return }
        app.typeKey("n", modifierFlags: .command)
        waitFor(app.windows.firstMatch, "a window after ⌘N — the app launched with none", timeout: 15)
    }
    #endif

    #if os(iOS)
    /// Turns the device the way the runner asked (`IPAD_ORIENTATION`, landscape by default on iPad).
    ///
    /// After `launch()`, not before: a rotation set before the app is up is silently dropped, and
    /// the set comes back portrait. The runner checks every shot's shape, so that fails the run.
    private func turnToRequestedOrientation() {
        guard ProcessInfo.processInfo.environment["SCREENSHOT_ORIENTATION"] == "landscape" else { return }
        XCUIDevice.shared.orientation = .landscapeLeft
        isLandscape = true
        settle()
    }
    #endif

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
        // A `List` is a collection view on iOS and an outline on the Mac.
        for candidate in [app.outlines.element(boundBy: 0), app.tables.element(boundBy: 0),
                          app.collectionViews.element(boundBy: 0)] where !sidebar.exists {
            sidebar = candidate
        }
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
        // Buttons first: a `List` row surfaces as a cell *containing* a button, and the cell often
        // carries the row's label too — clicking the button is the more reliable of the two.
        for query in [app.buttons, app.cells, app.radioButtons, app.descendants(matching: .tab)] {
            let matches = query.matching(predicate)
            if matches.count > 0 { return matches.element(boundBy: 0) }
        }
        return app.cells[name]   // nothing matched; let the caller's assertion name the miss
    }

    /// The `List` cell wrapping a row, for when the button inside it is not what a click has to land
    /// on.
    private func enclosingCell(labelled label: String) -> XCUIElement {
        app.cells.containing(NSPredicate(format: "label == %@ OR identifier == %@", label, label))
            .element(boundBy: 0)
    }

    /// Clicks or taps an element, retrying on the Mac until it has visibly taken effect.
    ///
    /// A click on a Mac window that is not key is spent activating the window rather than hitting
    /// what is under the pointer, so the first one can do nothing — XCTest says as much when it
    /// fails ("a retry-loop around the event may resolve the issue"). `until` is how this can tell
    /// the difference between a click that landed and one that was swallowed.
    private func activate(_ element: XCUIElement, _ description: String,
                          alternates: [XCUIElement] = [], until succeeded: (() -> Bool)? = nil) {
        guard waitFor(element, description) else { return }
        bringToFront()

        #if os(macOS)
        if let succeeded {
            // The row's own element first, then the cell wrapping it: which of the two a click has
            // to hit is not something the tree tells you, so try both rather than guess.
            var candidates = ([element] + alternates).filter(\.exists)
            if candidates.isEmpty { candidates = [element] }
            for attempt in 1 ... 4 {
                candidates[(attempt - 1) % candidates.count].click()
                for _ in 0 ..< 15 {
                    Thread.sleep(forTimeInterval: 0.2)
                    if succeeded() { return }
                }
            }
            XCTFail("clicked \(description) four times and nothing happened\n\(app.debugDescription)")
            return
        }
        element.click()
        #else
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
        #if os(macOS) || os(visionOS)
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
        attach(upright(XCUIScreen.main.screenshot()), named: name)
        #endif
    }

    /// The screenshot, turned the way the device is being held.
    ///
    /// `XCUIScreen.main.screenshot()` photographs the *physical* screen: a rotated device comes back
    /// as a portrait buffer carrying its quarter turn as metadata, which `XCTAttachment(screenshot:)`
    /// writes out content-on-its-side. Redrawing bakes the metadata into the pixels — `UIImage.size`
    /// is already the turned size and `draw(at:)` honours the orientation, so no manual rotation.
    private func upright(_ screenshot: XCUIScreenshot) -> XCTAttachment {
        #if os(iOS)
        guard isLandscape else { return XCTAttachment(screenshot: screenshot) }
        let image = screenshot.image
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale   // keep the pixel count the store checks against
        format.opaque = true
        return XCTAttachment(image: UIGraphicsImageRenderer(size: image.size, format: format).image { _ in
            image.draw(at: .zero)
        })
        #else
        XCTAttachment(screenshot: screenshot)
        #endif
    }

    private func attach(_ attachment: XCTAttachment, named name: String) {
        attachment.name = name
        attachment.lifetime = .keepAlways   // attachments on a passing test are discarded otherwise
        add(attachment)
    }

    #if os(macOS) || os(visionOS)

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
