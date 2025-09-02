struct User: Codable {
    let username: String?
    let email: String?
    let userType: String
    let nickname: String
    let avatarUrl: String?
    let isActive: Bool
    let isVerified: Bool
    let id: String
    let passwordHash: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case email
        case userType = "user_type"
        case nickname
        case avatarUrl = "avatar_url"
        case isActive = "is_active"
        case isVerified = "is_verified"
        case id
        case passwordHash = "password_hash"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
