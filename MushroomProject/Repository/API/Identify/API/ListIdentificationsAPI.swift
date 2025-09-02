import Alamofire

struct ListIdentificationsRequest: RequestProtocol {
    
    let limit: Int
    let offset: Int
    let lang: String
    
    init(limit: Int = 20, offset: Int = 0, lang: String = "en") {
        self.limit = limit
        self.offset = offset
        self.lang = lang
    }
    
    var path: String {
        return "api/mushrooms/identifications"
    }
    
    var needAuth: Bool {
        return true
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String : Any] {
        return [
            "limit": limit,
            "offset": offset,
            "lang": lang
        ]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct ListIdentificationsResponse: Codable {
    let total: Int
    let identifications: [IdentificationRecord]
}
