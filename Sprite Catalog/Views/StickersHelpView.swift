import SwiftUI

struct StickersHelpView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "1.circle.fill")
                Text("Open a sprite you want to add to your sticker collection.")
            }
            HStack {
                Image(systemName: "2.circle.fill")
                Text("Tap \(Image(systemName: "rectangle.stack.badge.plus")).")
            }
            HStack {
                Image(systemName: "3.circle.fill")
                Text("Tap the \"iMessage Stickers\" folder.")
            }
            HStack {
                Image(systemName: "4.circle.fill")
                Text("Open a conversation in Messages.")
            }
            HStack {
                Image(systemName: "5.circle.fill")
                Text("Tap \(Image(systemName: "plus.circle")) and then the Sprite Pencil app, and you can now send your sticker.")
            }
            Spacer()
        }
        .padding()
        .navigationTitle("How to send Stickers")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", systemImage: "checkmark") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    StickersHelpView()
}
