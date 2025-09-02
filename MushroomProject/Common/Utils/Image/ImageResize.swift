import Foundation
import UIKit

class ImageResize {
    
    class func resize(image: UIImage?, minLength: CGFloat, quality: CGImageQuality? = nil) -> UIImage? {
        guard let image = image else {
            debugPrint("[ImageResize] Error: Image is empty")
            return nil
        }
        
        guard minLength > 0 else {
            debugPrint("[ImageResize] Error: minLength error")
            return image
        }
        
        let size = image.size
        if min(size.width, size.height) <= minLength {
            return image
        }

        let imageScale = image.scale
        guard imageScale > 0 else {
            debugPrint("[ImageResize] Error: imageScale error")
            return image
        }
        
        var scale: CGFloat = 1.0
        let imageWidth = image.size.width * imageScale
        let imageHeight = image.size.height * imageScale
        
        if min(imageWidth, imageHeight) > minLength {
            scale = minLength / min(imageWidth, imageHeight)
        } else if max(imageWidth, imageHeight) < minLength {
            scale = minLength / max(imageWidth, imageHeight)
        }
        let targetSize = CGSize(width: imageWidth * scale, height: imageHeight * scale)
        return resize(image: image, size: targetSize, quality: quality)
    }
    
    class func resize(image: UIImage?, size: CGSize, quality: CGImageQuality? = nil) -> UIImage? {
        guard let quality = quality else {
            return CoreGraphicsResize.resize(image: image, size: size)
        }
        return CoreGraphicsResize.resize(image: image, size: size, quality: quality)
    }
}

