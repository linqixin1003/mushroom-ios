//
//  MushroomIdentificationRecord.swift
//  RockProject
//
//  Created by conalin on 2025/5/20.
//

struct MushroomIdentificationRecord: Codable, Identifiable {
    let id: Int
    let uid: String
    let confidence: Double
    let createdAt: String
    let imageUrl: String
    let latinName: String
    let commonName: String

    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case confidence
        case createdAt = "created_at"
        case imageUrl = "image_url"
        case latinName = "latin_name"
        case commonName = "common_name"
    }
}
