import Foundation
// 需要引入LocalRecordItem的定义
// import 相关模块或确保LocalRecordItem在同一模块中

// 心愿单项目 - 参考Android WishRecord结构
struct WishListItem: Codable, Identifiable {
    let id: Int
    let mushroomId: String
    let name: String
    let description: String
    let photoUrl: String
    let chemicalFormula: String
    let colors: String
    let hardness: String
    let tags: [WishTag]
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case mushroomId = "mushroom_id"
        case name
        case description
        case photoUrl = "photo_url"
        case chemicalFormula = "chemical_formula"
        case colors
        case hardness
        case tags
        case createdAt = "created_at"
    }
}

// 心愿单标签
struct WishTag: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String
}

// 本地心愿单项目（用于本地存储）
struct LocalWishListItem: Codable, Identifiable {
    let id: String
    let mushroomId: String
    let name: String
    let imageUrl: String
    let description: String
    let chemicalFormula: String
    let colors: String
    let hardness: String
    let tags: [WishTag]
    let createdAt: String
    
    // 从WishListItem转换
    static func from(_ item: WishListItem) -> LocalWishListItem {
        return LocalWishListItem(
            id: String(item.id),
            mushroomId: item.mushroomId,
            name: item.name,
            imageUrl: item.photoUrl,
            description: item.description,
            chemicalFormula: item.chemicalFormula,
            colors: item.colors,
            hardness: item.hardness,
            tags: item.tags,
            createdAt: item.createdAt
        )
    }
    
}