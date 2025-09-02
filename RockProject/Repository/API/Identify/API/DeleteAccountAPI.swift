import Alamofire

struct AccountManagerRequest: RequestProtocol {
    
    let lang: String
    
    init(lang: String = "en") {
        self.lang = lang
    }
    
    var path: String {
        return "api/users/account"
    }
    
    var needAuth: Bool {
        return true
    }
    
    var method: HTTPMethod {
        return .delete
    }
    
    var parameters: [String : Any] {
        return [
            "lang": lang
        ]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}
