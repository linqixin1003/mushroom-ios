import Alamofire
import Foundation

class ItemRepository {

    public static func listIdentificationsAsync(limit: Int = 20, offset: Int = 0, lang: String = "en") async -> ListIdentificationsResponse? {
        let req = ListIdentificationsRequest(limit: limit, offset: offset, lang: lang)
        return try? await ApiRequest.requestAsync(request: req)
    }

    public static func identifyAsync(image: Data, lang: String) async -> IdentifyResponse? {
        let req = IdentifyRequest(image: image, lang: lang)
        return try? await ApiRequest.requestAsync(request: req)
    }
    
    public static func randomAsync(lang: String = "en") async -> RandomStoneResponse? {
        let req = RandomStoneRequest(lang: lang)
        return try? await ApiRequest.requestAsync(request: req)
    }
    
    public static func getDetailAsync(stoneId: String, language: String = "en") async -> GetDetailResponse? {
        let req = GetDetailRequest(stoneId: stoneId, language: language)
        return try? await ApiRequest.requestAsync(request: req)
    }
    
    public static func searchAsync(query: String, limit: Int = 20, offset: Int = 0, lang: String = "en") async -> SearchStoneResponse? {
        let req = SearchStoneRequest(query: query, limit: limit, offset: offset, lang: lang)
        return try? await ApiRequest.requestAsync(request: req)
    }
}
