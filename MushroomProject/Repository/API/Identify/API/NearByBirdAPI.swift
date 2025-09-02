import Alamofire
import Foundation

struct NearByMushroomRequest: RequestProtocol {
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
        return "api/mushrooms/nearby"
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

struct NearByMushroomResponse: Codable {
    let total: Int
    let mushrooms: [SimpleMushroom]
}

struct SimpleMushroom: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let photoUrl: String?
    let scientificName: String?
    let chineseName: String?
    let organismType: String?
    let edibility: String?
    let habitat: String?
    let tags: [MushroomTag]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, tags
        case photoUrl = "photo_url"
        case scientificName = "scientific_name"
        case chineseName = "chinese_name"
        case organismType = "organism_type"
        case edibility, habitat
    }
    
    init(id: String, name: String, description: String, photoUrl: String, 
         scientificName: String, chineseName: String? = nil, organismType: String,
         edibility: String? = nil, habitat: String? = nil, tags: [MushroomTag] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.photoUrl = photoUrl
        self.scientificName = scientificName
        self.chineseName = chineseName
        self.organismType = organismType
        self.edibility = edibility
        self.habitat = habitat
        self.tags = tags
    }
    
}

struct MushroomTag: Codable {
    let id: Int
    let name: String
    let slug: String
}
