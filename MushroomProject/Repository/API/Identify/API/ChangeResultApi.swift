import Foundation
import Alamofire

struct ChangeResultRequest: RequestProtocol {
    let identificationId: Int
    let newStoneId: String
    let confidence: Double
    
    init(identificationId: Int, newStoneId: String, confidence:Double) {
        self.identificationId = identificationId
        self.newStoneId = newStoneId
        self.confidence = confidence
    }
    
    var path: String {
        return "api/stones/changeidentifyresult"
    }
    
    var needAuth: Bool {
        return false
    }
    
    var method: HTTPMethod {
        return .put
    }
    
    var parameters: [String : Any] {
        return ["identification_id":identificationId, "new_stone_id":newStoneId, "confidence":confidence]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct ChangeResultResponse: Codable {
    let success: Bool
    let identificationId: Int
    let message: String
    enum CodingKeys: String, CodingKey {
        case success
        case identificationId = "identification_id"
        case message
    }
}
