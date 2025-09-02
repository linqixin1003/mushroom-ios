import Alamofire

protocol RequestProtocol {
    
    var path: String { get }
    
    var needAuth: Bool { get }
    
    var method: HTTPMethod { get }
    
    var parameters: [String: Any] { get }
    
    var multipartFormData: ((MultipartFormData) -> Void)? { get }
}
