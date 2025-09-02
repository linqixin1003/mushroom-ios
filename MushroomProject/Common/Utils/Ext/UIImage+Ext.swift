import UIKit

extension UIImage {
    
    public func toAPIData() throws -> Data {
        let qualityFactor = 0.9
        let minSize = 512.0
        let imgSize = self.size
        var smallImage = self
        if min(imgSize.width, imgSize.height) > minSize + 10.0 {
            if let img = ImageResize.resize(image: self, minLength: minSize) {
                smallImage = img
            }
        }
        guard let data = smallImage.jpegData(compressionQuality: qualityFactor) else {
            debugPrint("resize image failed.")
            return self.jpegData(compressionQuality: 0.5) ?? Data()
        }
        return data
    }
}
