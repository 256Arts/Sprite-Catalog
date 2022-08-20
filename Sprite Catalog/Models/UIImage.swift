//
//  UIImage.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-05-07.
//

import UIKit
import CoreImage.CIFilterBuiltins

extension UIImage {
    
    func hueRotate(angle degrees: Double) -> UIImage? {
        return self
        // iOS 14.5 BUG: UIImage(ciImage:) will double the resolution
        
//        guard !degrees.isZero else { return self }
//        let filter = CIFilter.hueAdjust()
//        filter.angle = Float(degrees * (.pi / 180.0))
//        filter.inputImage = CIImage(image: self)
//        guard let outputImage = filter.outputImage else {
//            print("Failed to apply hue filter")
//            return nil
//        }
//        return UIImage(ciImage: outputImage)
    }
    
}
