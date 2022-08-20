//
//  SpriteSubmissionView.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-04-01.
//

import SwiftUI
import MessageUI

struct SpriteSubmissionView: View {
    
    class MailDelegate: NSObject, MFMailComposeViewControllerDelegate {
        static let shared = MailDelegate()
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var artistName = ""
    @State var artistWebsite = ""
    @State var licence: Licence = .cc0
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Artist Name", text: $artistName)
                TextField("Artist Website (Optional)", text: $artistWebsite)
                Picker("Licence", selection: $licence) {
                    ForEach(Licence.allCases) { (licence) in
                        Text("\(licence.name) (\(licence.rawValue))")
                            .tag(licence)
                    }
                }
            }
            .navigationTitle("Submit Your Sprites")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Next") {
                        guard MFMailComposeViewController.canSendMail() else { return }
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            let composeVC = MFMailComposeViewController()
                            composeVC.mailComposeDelegate = MailDelegate.shared
                            composeVC.setToRecipients(["info@jaydenirwin.com"])
                            composeVC.setSubject("Sprite Submission")
                            composeVC.setMessageBody("Hello, I have a sprite submission for Sprite Catalog.\n\nArtist Name: \(artistName)\nArtist Website (Optional): \(artistWebsite)\nLicence: \(licence.rawValue)\nSprite Images:\n\n<Attach Images Here>", isHTML: false)
                            scene.windows.first?.rootViewController?.presentedViewController?.present(composeVC, animated: true)
                        }
                    }
                    .disabled(artistName.isEmpty)
                }
            }
        }
    }
}

struct SpriteSubmissionView_Previews: PreviewProvider {
    static var previews: some View {
        SpriteSubmissionView()
    }
}
