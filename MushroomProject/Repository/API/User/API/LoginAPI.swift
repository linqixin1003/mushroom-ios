
import Alamofire

struct LoginRequest: RequestProtocol {
    
    var path: String {
        return "api/users/login"
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
        return nil
    }
}

struct LoginResponse: Codable {
    let userId: String
    let isVip: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isVip = "isVip"
    }
}
