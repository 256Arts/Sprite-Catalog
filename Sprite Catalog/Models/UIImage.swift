import UIKit
import CoreImage.CIFilterBuiltins

enum ImageEditError: Error {
    case failedToApplyFilter
}

extension UIImage {
    
    func hueRotate(angle degrees: Double) throws -> UIImage {
        guard !degrees.isZero else { return self }
        
        let filter = CIFilter.hueAdjust()
        filter.angle = Float(degrees * (.pi / 180.0))
        filter.inputImage = CIImage(image: self)
        guard let outputImage = filter.outputImage else {
            throw ImageEditError.failedToApplyFilter
        }
        return UIImage(ciImage: outputImage)
    }
    
}
