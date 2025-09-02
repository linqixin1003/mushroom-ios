import Foundation
import Alamofire

// iOS 估价请求：对齐 Android ValuationRequest(api/mushrooms/grading)
struct ValuationRequest: RequestProtocol {
    let image: Data

    var path: String { "api/mushrooms/grading" }
    var needAuth: Bool { false }
    var method: HTTPMethod { .post }
    var parameters: [String : Any] { [:] }

    var multipartFormData: ((MultipartFormData) -> Void)? {
        return { form in
            form.append(image, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
        }
    }
}

// iOS 估价响应：对齐 Android ValuationResponse
struct ValuationResponse: Codable {
    let estimatedPrice: Double
    let minPrice: Double
    let maxPrice: Double
    let currency: String
    let confidence: Double
    let reasoning: String
    let mushroomType: String
    let qualityAssessment: String

    enum CodingKeys: String, CodingKey {
        case estimatedPrice = "estimated_price"
        case minPrice = "min_price"
        case maxPrice = "max_price"
        case currency
        case confidence
        case reasoning
        case mushroomType = "mushroom_type"
        case qualityAssessment = "quality_assessment"
    }
}