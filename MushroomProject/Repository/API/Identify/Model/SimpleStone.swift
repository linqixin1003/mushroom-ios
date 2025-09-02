import Foundation

/**
 * Simple stone information model
 */
struct SimpleStone: Codable {
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
}

struct StoneTag: Codable {
    let id: Int
    let name: String
    let slug: String
}