import Alamofire

struct RandomMushroomRequest: RequestProtocol {
    
    let lang: String
    
    init(lang: String = "en") {
        self.lang = lang
    }
    
    var path: String {
        return "api/mushrooms/recommend"
    }
    
    var needAuth: Bool {
        return false
    }
    
    var method: HTTPMethod {
        return .get
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

struct RandomMushroomResponse: Codable {
    let date: String
    let mushrooms: [SimpleMushroom]
}
