import Alamofire

struct DailyRequest: RequestProtocol {
    
    var path: String {
        return "api/stones/daily"
    }
    
    var needAuth: Bool {
        return false
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String : Any] {
        return [:]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct DailyResponse: Codable {
    let date: String
    let stones: [DailyStone]
}

struct DailyStone: Codable {
    let id: String
    let name: String
    let description: String
    let photoUrl: String
    let chemicalFormula: String
    let hardness: String
    let crystalSystem: String
    let density: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, hardness, density
        case photoUrl = "photo_url"
        case chemicalFormula = "chemical_formula"
        case crystalSystem = "crystal_system"
    }
    
    /// 转换为SimpleStone
    func toSimpleStone() -> SimpleStone {
        return SimpleStone(
            id: self.id,
            name: self.name,
            description: self.description,
            photoUrl: self.photoUrl,
            chemicalFormula: self.chemicalFormula,
            colors: "", // DailyStone没有colors字段，使用空字符串
            hardness: self.hardness,
            tags: [] // DailyStone没有tags字段，使用空数组
        )
    }
}
