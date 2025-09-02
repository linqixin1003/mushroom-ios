//
//  MushroomFeatures.swift
//  RockProject
//
//  Created by conalin on 2025/6/10.
//

import SwiftUI

struct MushroomObservation: Codable, Identifiable {
    let id: Int // sequence_id
    let colors: MushroomColors
    let environment: MushroomEnvironment
    let behavior: MushroomBehavior
    let size: MushroomSize
    let season: MushroomSeason
    let plumageId: Int
    
    struct MushroomColors: Codable {
        let black: Bool
        let blue: Bool
        let brown: Bool
        let gray: Bool
        let green: Bool
        let orange: Bool
        let red: Bool
        let white: Bool
        let yellow: Bool
    }
    
    struct MushroomEnvironment: Codable {
        let feeder: Bool
        let fence: Bool
        let ground: Bool
        let trees: Bool
        let water: Bool
    }
    
    struct MushroomBehavior: Codable {
        let flying: Bool
    }
    
    struct MushroomSize: Codable {
        let size1: Bool
        let size2: Bool
        let size3: Bool
        let size4: Bool
        let size5: Bool
        let size6: Bool
        let size7: Bool
    }
    
    struct MushroomSeason: Codable {
        let monthStart: Int
        let monthEnd: Int
    }
}

struct MushroomDetailView: View {
    let observation: MushroomObservation
    
    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                ColorsCard(colors: observation.colors)
                EnvironmentCard(environment: observation.environment)
                BehaviorCard(behavior: observation.behavior)
                SizeCard(size: observation.size)
                PlumageCard(plumageId: observation.plumageId)
                SeasonCard(season: observation.season)
            }
        }
    }
}

// 统一的卡片样式
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// 修改各个卡片组件，使用统一的 CardView
struct BasicInfoCard: View {
    let observation: MushroomObservation
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(Language.stone_basic_information)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    InfoItem(title: Language.stone_observation_number, value: "\(observation.id)")
                }
            }
        }
    }
}

struct InfoItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

struct ColorsCard: View {
    let colors: MushroomObservation.MushroomColors

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(Language.stone_color_features)
                    .font(.headline)
                    .foregroundColor(.appText)
                // 4列色块，左对齐
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8, alignment: .leading), count: 4),
                    alignment: .leading,
                    spacing: 12
                ) {
                    if colors.black { ColorBlock(color: .black, name: "Black") }
                    if colors.blue { ColorBlock(color: .blue, name: "Blue") }
                    if colors.brown { ColorBlock(color: .brown, name: "Brown") }
                    if colors.gray { ColorBlock(color: .gray, name: "Gray") }
                    if colors.green { ColorBlock(color: .green, name: "Green") }
                    if colors.orange { ColorBlock(color: .orange, name: "Orange") }
                    if colors.red { ColorBlock(color: .red, name: "Red") }
                    if colors.white { ColorBlock(color: .white, name: "White") }
                    if colors.yellow { ColorBlock(color: .yellow, name: "Yellow") }
                }
            }
        }
    }
}

struct ColorBlock: View {
    let color: Color
    let name: String

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .frame(height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            Text(name)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct EnvironmentCard: View {
    let environment: MushroomObservation.MushroomEnvironment

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(Language.stone_habitat)
                    .font(.headline)
                    .foregroundColor(.appText)
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                    spacing: 16
                ) {
                    EnvironmentItem(name: "Near Feeder", isPresent: environment.feeder)
                    EnvironmentItem(name: "Near Fence", isPresent: environment.fence)
                    EnvironmentItem(name: "Ground", isPresent: environment.ground)
                    EnvironmentItem(name: "In Trees", isPresent: environment.trees)
                    EnvironmentItem(name: "Near Water", isPresent: environment.water)
                }
            }
        }
    }
}

struct EnvironmentItem: View {
    let name: String
    let isPresent: Bool

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isPresent ? Color.green : Color.red)
                    .frame(width: 16, height: 16)
                Image(systemName: isPresent ? "checkmark" : "xmark")
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .bold))
            }
            Text(name)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .fixedSize()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BehaviorCard: View {
    let behavior: MushroomObservation.MushroomBehavior

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(Language.stone_behavior)
                    .font(.headline)
                    .foregroundColor(.appText)
                
                // 使用 HStack 并添加 Spacer() 让内容横向铺满
                HStack {
                    Image(systemName: behavior.flying ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(behavior.flying ? .green : .red)
                        .font(.caption)
                    Text(Language.stone_flying)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer() // 添加 Spacer 让内容横向铺满
                }
            }
        }
    }
}

struct SizeCard: View {
    let size: MushroomObservation.MushroomSize

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(Language.stone_size)
                    .font(.headline)
                    .foregroundColor(.appText)
                if let range = getSizeRange(size: size) {
                    HStack {
                        Text(sizeRangeText(min: range.min, max: range.max))
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                } else {
                    Text(Language.stone_no_data)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

func getSizeRange(size: MushroomObservation.MushroomSize) -> (min: MushroomSizeInfo, max: MushroomSizeInfo)? {
    let flags = [
        size.size1, size.size2, size.size3, size.size4,
        size.size5, size.size6, size.size7
    ]
    var start: Int? = nil
    var end: Int? = nil
    for (i, flag) in flags.enumerated() {
        if flag {
            if start == nil { start = i }
            end = i
        }
    }
    if let s = start, let e = end {
        return (stoneSizeList[s], stoneSizeList[e])
    }
    return nil
}

func sizeRangeText(min: MushroomSizeInfo, max: MushroomSizeInfo) -> String {
    let cmText: String
    if let maxCm = max.cmMax {
        cmText = "\(min.cmMin)~\(maxCm)cm"
    } else {
        cmText = "\(min.cmMin)cm+"
    }
    let inchText: String
    if let maxInch = max.inchMax {
        inchText = "(\(min.inchMin)~\(maxInch)in)"
    } else {
        inchText = "(\(min.inchMin)in+)"
    }
    return "\(cmText) \(inchText)"
}

struct SeasonCard: View {
    let season: MushroomObservation.MushroomSeason

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(Language.stone_season_info)
                    .font(.headline)
                    .foregroundColor(.appText)
                HStack {
                    Text(Language.stone_visible_months)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 当月份范围是 1-12 时显示"全年可见"，否则显示具体月份
                    if season.monthStart == 1 && season.monthEnd == 12 {
                        Text(Language.stone_visible_year_round)
                            .font(.body)
                            .foregroundColor(.primary)
                    } else {
                        Text("\(season.monthStart) - \(season.monthEnd)")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer() // 让内容横向撑满
                }
            }
        }
    }
}

struct PlumageCard: View {
    let plumageId: Int

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(Language.stone_plumage)
                    .font(.headline)
                    .foregroundColor(.appText)
                HStack {
                    Text(PlumageType(rawValue: plumageId)?.description ?? "Unknown")
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer() // 让内容横向铺满
                }
            }
        }
    }
}

struct MushroomSizeInfo {
    let name: String
    let cmMin: Int
    let cmMax: Int?
    let inchMin: Int
    let inchMax: Int?
}

let stoneSizeList: [MushroomSizeInfo] = [
    MushroomSizeInfo(name: "Very Small", cmMin: 8, cmMax: 12, inchMin: 3, inchMax: 5),
    MushroomSizeInfo(name: "Small", cmMin: 13, cmMax: 16, inchMin: 5, inchMax: 6),
    MushroomSizeInfo(name: "Small-Medium", cmMin: 17, cmMax: 20, inchMin: 6, inchMax: 8),
    MushroomSizeInfo(name: "Medium", cmMin: 21, cmMax: 25, inchMin: 8, inchMax: 10),
    MushroomSizeInfo(name: "Medium-Large", cmMin: 26, cmMax: 30, inchMin: 10, inchMax: 12),
    MushroomSizeInfo(name: "Large", cmMin: 31, cmMax: 40, inchMin: 12, inchMax: 16),
    MushroomSizeInfo(name: "Very Large", cmMin: 41, cmMax: nil, inchMin: 16, inchMax: nil)
]

struct ContentView: View {
    let observation = MushroomObservation(
        id: 11651,
        colors: MushroomObservation.MushroomColors(
            black: true,
            blue: true,
            brown: true,
            gray: true,
            green: false,
            orange: false,
            red: false,
            white: true,
            yellow: true
        ),
        environment: MushroomObservation.MushroomEnvironment(
            feeder: false,
            fence: true,
            ground: true,
            trees: true,
            water: false
        ),
        behavior: MushroomObservation.MushroomBehavior(flying: true),
        size: MushroomObservation.MushroomSize(
            size1: false,
            size2: false,
            size3: false,
            size4: false,
            size5: true,
            size6: true,
            size7: true
        ),
        season: MushroomObservation.MushroomSeason(
            monthStart: 1,
            monthEnd: 12
        ),
        plumageId: 10
    )
    
    var body: some View {
        NavigationView {
            MushroomDetailView(observation: observation)
        }
    }
}

#Preview {
    // 创建示例数据
    let sampleObservation = MushroomObservation(
        id: 11651,
        colors: MushroomObservation.MushroomColors(
            black: true,
            blue: true,
            brown: true,
            gray: true,
            green: false,
            orange: false,
            red: false,
            white: true,
            yellow: true
        ),
        environment: MushroomObservation.MushroomEnvironment(
            feeder: false,
            fence: true,
            ground: true,
            trees: true,
            water: false
        ),
        behavior: MushroomObservation.MushroomBehavior(flying: true),
        size: MushroomObservation.MushroomSize(
            size1: false,
            size2: false,
            size3: false,
            size4: false,
            size5: true,
            size6: true,
            size7: true
        ),
        season: MushroomObservation.MushroomSeason(
            monthStart: 1,
            monthEnd: 12
        ),
        plumageId: 10
    )
    
    return NavigationView {
        MushroomDetailView(observation: sampleObservation)
    }
}

enum PlumageType: Int, CaseIterable {
    case unknown = 0
    case breeding = 10           // Breeding plumage
    case nonBreeding = 440       // Non-breeding plumage
    case juvenile = 100          // Juvenile plumage
    case immature = 110          // Immature plumage
    case adultMale = 200         // Adult male plumage
    case adultFemale = 300       // Adult female plumage
    case firstWinter = 120       // First winter plumage
    case firstSummer = 130       // First summer plumage
    case winter = 140            // Winter plumage
    case summer = 150            // Summer plumage
    case transitional = 160      // Transitional plumage
    // ...extend as needed
}

extension PlumageType {
    var description: String {
        switch self {
        case .breeding:
            return "Breeding plumage"
        case .nonBreeding:
            return "Non-breeding plumage"
        case .juvenile:
            return "Juvenile plumage"
        case .immature:
            return "Immature plumage"
        case .adultMale:
            return "Adult male plumage"
        case .adultFemale:
            return "Adult female plumage"
        case .firstWinter:
            return "First winter plumage"
        case .firstSummer:
            return "First summer plumage"
        case .winter:
            return "Winter plumage"
        case .summer:
            return "Summer plumage"
        case .transitional:
            return "Transitional plumage"
        case .unknown:
            return "Unknown"
        }
    }

    var priority: Int {
        switch self {
        case .breeding: return 1
        case .nonBreeding: return 2
        case .adultMale: return 3
        case .adultFemale: return 4
        case .juvenile: return 5
        case .immature: return 6
        case .firstWinter: return 7
        case .firstSummer: return 8
        case .winter: return 9
        case .summer: return 10
        case .transitional: return 11
        case .unknown: return 99
        }
    }
}

func selectMostCommonPlumage(from ids: [Int]) -> PlumageType {
    let types = ids.compactMap { PlumageType(rawValue: $0) }
    return types.sorted { $0.priority < $1.priority }.first ?? .unknown
}


