//
//  ShareTextSource.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-03-28.
//

import UIKit
import LinkPresentation

class ShareTextSource: NSObject, UIActivityItemSource {
    
    var spriteTitle: String
    var image: UIImage?
    
    init(image: UIImage?, title: String) {
        self.image = image
        self.spriteTitle = title
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        NSLocalizedString("Created in Sprite Pencil.", comment: "")
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType == .postToTwitter {
            return NSLocalizedString("Created in @SpritePencil.", comment: "twitter share text")
        } else {
            return NSLocalizedString("Created in Sprite Pencil.", comment: "")
        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        NSLocalizedString("Pixel Art", comment: "email subject")
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = spriteTitle
        if let image = image {
            metadata.imageProvider = NSItemProvider(object: image)
        }
        return metadata
    }
    
}
