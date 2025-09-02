
import Alamofire

struct GetDetailRequest: RequestProtocol {
    let stoneId: String
    let language: String
    
    init(stoneId: String, language: String = "en") {
        self.stoneId = stoneId
        self.language = language
    }
    
    var path: String {
        return "api/stones/\(stoneId)"
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
    let stone: Stone
    let isInWishlist: Bool
    
    enum CodingKeys: String, CodingKey {
        case stone
        case isInWishlist = "is_in_wishlist"
    }
}
