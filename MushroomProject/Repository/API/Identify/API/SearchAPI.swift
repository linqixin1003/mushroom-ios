
import Alamofire

struct SearchStoneRequest: RequestProtocol {
    
    let query: String
    let limit: Int
    let offset: Int
    let lang: String
    
    var path: String {
        return "api/mushrooms/search"
    }
    
    var needAuth: Bool {
        return false
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String : Any] {
        return [
            "query": query,
            "limit": limit,
            "offset": offset,
            "lang": lang
        ]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct SearchStoneResponse: Codable {
    let total: Int
    let stones: [SimpleStone]
}

