
import Alamofire

struct GetDetailRequest: RequestProtocol {
    let mushroomId: String
    let language: String
    
    init(mushroomId: String, language: String = "en") {
        self.mushroomId = mushroomId
        self.language = language
    }
    
    var path: String {
        return "api/mushrooms/\(mushroomId)"
    }
    
    var needAuth: Bool {
        return true
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String : Any] {
        return ["lang": language]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct GetDetailResponse: Codable {
    let mushroom: Mushroom
    let isInWishlist: Bool
    
    enum CodingKeys: String, CodingKey {
        case mushroom
        case isInWishlist = "is_in_wishlist"
    }
}
