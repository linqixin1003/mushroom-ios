import UIKit
import CoreGraphics

@objc public enum CGImageQuality : Int {
    case none
    case high
}

class CoreGraphicsResize : NSObject {
    
    class func resize(image: UIImage?, size: CGSize, quality: CGImageQuality? = .high) -> UIImage? {
        switch quality {
        case .high:
            return resizeHighQuality(image, size: size)
        default:
            return resizeDefaultQuality(image, size: size)
        }
    }
    
    class func resizeDefaultQuality(_ image: UIImage?, size: CGSize) -> UIImage? {
        guard let image = image else {
            return nil
        }
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        let reult = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return reult
    }
    
    class func resizeHighQuality(_ image: UIImage?, size: CGSize) -> UIImage? {
        guard let image = image else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = .high
        image.draw(in: CGRect(origin: .zero, size: size))

        guard let newCGImage = context?.makeImage() else { return nil }
        let newImage = UIImage(cgImage: newCGImage)

        UIGraphicsEndImageContext()

        return newImage
    }
}

