
struct IdentificationRecord: Codable {
    let id: Int
    let userId: String
    let mushroomId: String
    let name: String
    let imageUrl: String
    let confidence: Double
    let source: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case mushroomId = "mushroom_id"
        case name
        case imageUrl = "image_url"
        case confidence
        case source
        case createdAt = "created_at"
    }
}
