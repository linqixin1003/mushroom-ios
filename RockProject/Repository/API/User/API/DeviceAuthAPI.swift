
import Alamofire

struct DeviceAuthRequest: RequestProtocol {
    
    var path: String {
        return "api/users/auth/device"
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

struct DeviceAuthResponse: Codable {
    let accessToken: String
    let tokenType: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case user
    }
}
