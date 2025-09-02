
struct Observation: Codable {
    let id: Int
    let black: Bool
    let blue: Bool
    let brown: Bool
    let feeder: Bool
    let fence: Bool
    let flying: Bool
    let gray: Bool
    let green: Bool
    let ground: Bool
    let monthStart: Int
    let monthEnd: Int
    let orange: Bool
    let plumageId: Int
    let red: Bool
    let size1: Bool
    let size2: Bool
    let size3: Bool
    let size4: Bool
    let size5: Bool
    let size6: Bool
    let size7: Bool
    let trees: Bool
    let water: Bool
    let white: Bool
    let yellow: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "sequence_id"
        case black, blue, brown, feeder, fence, flying, gray, green, ground
        case monthStart = "month_start"
        case monthEnd = "month_end"
        case orange
        case plumageId = "plumage_id"
        case red, size1, size2, size3, size4, size5, size6, size7, trees, water, white, yellow
    }
}
