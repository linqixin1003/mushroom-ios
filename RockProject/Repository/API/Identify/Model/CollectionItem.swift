import Foundation


// 收藏记录 - 对齐Android的CollectionRecord结构
struct CollectionRecord: Codable, Identifiable {
    let id: Int	
    let identificationId: Int
    let stoneId: String
    let name: String
    let description: String
    let imageUrl: String
    let stonePhotoUrl: String
    let chemicalFormula: String
    let colors: String
    let hardness: String
    let confidenceScore: Float
    let modelVersion: String
    let processingTime: Int
    let tags: [StoneTag]
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case identificationId = "identification_id"
        case stoneId = "stone_id"
        case name
        case description
        case imageUrl = "image_url"
        case stonePhotoUrl = "stone_photo_url"
        case chemicalFormula = "chemical_formula"
        case colors
        case hardness
        case confidenceScore = "confidence_score"
        case modelVersion = "model_version"
        case processingTime = "processing_time"
        case tags
        case createdAt = "created_at"
    }
    
    // 转换为LocalRecordItem用于显示
    func toLocalRecordItem() -> LocalRecordItem {
        return LocalRecordItem(
            id: "collection_\(id)",
            uid: stoneId,
            type: .image,
            createdAt: createdAt,
            confidence: confidenceScore,
            latinName: chemicalFormula,
            commonName: name,
            mediaUrl: imageUrl.isEmpty ? stonePhotoUrl : imageUrl
        )
    }
}

// WishTag结构已经在WishListItem.swift中定义，这里不需要重复定义
