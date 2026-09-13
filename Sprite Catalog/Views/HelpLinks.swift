import SwiftUI

/// The app's outbound links. The Mac menu bar shows them under Help, where a desktop user looks for
/// them; everywhere else they sit in the sidebar's overflow menu.
struct HelpLinks: View {

    var body: some View {
        Link(destination: URL(string: "https://www.256arts.com/spritecatalog/")!) {
            Label("Sprite Catalog Help", systemImage: "questionmark.circle")
        }
        Link(destination: URL(string: "https://www.256arts.com/")!) {
            Label("Developer Website", systemImage: "safari")
        }
        Link(destination: URL(string: "https://www.256arts.com/joincommunity/")!) {
            Label("Join Community", systemImage: "bubble.left.and.bubble.right")
        }
        Link(destination: URL(string: "https://form.jotform.com/211994359527266")!) {
            Label("Submit Your Sprites", systemImage: "paperplane")
        }
        Link(destination: URL(string: "https://github.com/256Arts/Sprite-Catalog")!) {
            Label("Contribute on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
        }
    }

}
