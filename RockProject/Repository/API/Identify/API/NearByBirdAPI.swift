import Alamofire
import Foundation

struct NearByStoneRequest: RequestProtocol {
    let longitude: Float
    let latitude: Float
    let radiusKm: Int
    let limit: Int
    let lang: String
    
    init(longitude: Float, latitude: Float, radiusKm: Int = 100, limit: Int = 50, lang: String = "en") {
        self.longitude = longitude
        self.latitude = latitude
        self.radiusKm = radiusKm
        self.limit = limit
        self.lang = lang
    }
    
    var path: String {
        return "api/stones/nearby"
    }
    
    var needAuth: Bool {
        return false
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String : Any] {
        return [
            "longitude": longitude,
            "latitude": latitude,
            "radius_km": radiusKm,
            "limit": limit,
            "lang": lang
        ]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct NearByStoneResponse: Codable {
    let total: Int
    let stones: [NearStone]
}

struct NearStone: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let photoUrl: String
    let chemicalFormula: String
    let colors: String
    let hardness: String
    let tags: [StoneTag]
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, colors, hardness, tags
        case photoUrl = "photo_url"
        case chemicalFormula = "chemical_formula"
    }
    
    /// 转换为SimpleStone
    func toSimpleStone() -> SimpleStone {
        return SimpleStone(
            id: self.id,
            name: self.name,
            description: self.description,
            photoUrl: self.photoUrl,
            chemicalFormula: self.chemicalFormula,
            colors: self.colors,
            hardness: self.hardness,
            tags: self.tags
        )
    }
}
