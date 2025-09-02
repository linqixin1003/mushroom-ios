import Foundation
import Alamofire

struct IdentifyRequest: RequestProtocol {
    
    let image: Data
    let source: String
    let longitude: Double
    let latitude: Double
    let lang: String
    
    init(image: Data, source: String = "camera", longitude: Double = 0.0, latitude: Double = 0.0, lang: String = "en") {
        self.image = image
        self.source = source
        self.longitude = longitude
        self.latitude = latitude
        self.lang = lang
    }
    
    var path: String {
        return "api/stones/identify"
    }
    
    var needAuth: Bool {
        return false
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var parameters: [String : Any] {
        return [:]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return { multipartFormData in
            // 添加图片数据
            multipartFormData.append(image, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            
            // 添加表单参数
            if let langData = lang.data(using: .utf8) {
                multipartFormData.append(langData, withName: "lang")
            }
            
            if let longitudeData = String(longitude).data(using: .utf8) {
                multipartFormData.append(longitudeData, withName: "longitude")
            }
            
            if let latitudeData = String(latitude).data(using: .utf8) {
                multipartFormData.append(latitudeData, withName: "latitude")
            }
            
            if let sourceData = source.data(using: .utf8) {
                multipartFormData.append(sourceData, withName: "source")
            }
        }
    }
}

struct IdentifyResponse: Codable {
    let results: [IdentifyItem]
    enum CodingKeys: String, CodingKey {
        case results
    }
}

struct IdentifyItem:Codable{
    let stone: Stone
    let confidence: Double
    let identificationId: Int?
    var isInWishlist: Bool
    
    enum CodingKeys: String, CodingKey {
        case stone
        case confidence
        case identificationId = "identification_id"
        case isInWishlist = "is_in_wishlist"
    }
}

