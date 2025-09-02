import Foundation
import Alamofire

struct ChangeResultRequest: RequestProtocol {
    let identificationId: Int
    let newMushroomId: String
    let confidence: Double
    
    init(identificationId: Int, newMushroomId: String, confidence:Double) {
        self.identificationId = identificationId
        self.newMushroomId = newMushroomId
        self.confidence = confidence
    }
    
    var path: String {
        return "api/mushrooms/changeidentifyresult"
    }
    
    var needAuth: Bool {
        return false
    }
    
    var method: HTTPMethod {
        return .put
    }
    
    var parameters: [String : Any] {
        return ["identification_id":identificationId, "new_stone_id":newMushroomId, "confidence":confidence]
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
