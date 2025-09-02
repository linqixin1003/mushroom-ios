import SwiftUI

struct StoneInfoSectionView: View {
    let stone: Stone
    
    // 检查是否有任何详细信息
    private var hasAnyDetailedInfo: Bool {
        let hasCharacteristics = !(stone.description ?? "").isEmpty ||
                                !(stone.usage ?? "").isEmpty ||
                                (stone.healthRisks?.isEmpty == false) ||
                                !(stone.originalVsFake ?? "").isEmpty ||
                                !(stone.storage ?? "").isEmpty
        
        let hasClassification = !(stone.chemicalFormula ?? "").isEmpty ||
                               !(stone.chemicalClassification ?? "").isEmpty ||
                               !(stone.crystalSystem ?? "").isEmpty ||
                               !(stone.hardness ?? "").isEmpty
        
        return hasCharacteristics || hasClassification
    }
    
    var body: some View {
        if hasAnyDetailedInfo {
            VStack(spacing: 12.rpx) {
                // Characteristics 特征部分
                StoneCharacteristicsSection(stone: stone)
                
                // Chemical classification 化学分类部分
                StoneChemicalClassificationSection(stone: stone)
            }
            .background(Color.clear)
        } else {
            // 当没有详细信息时显示占位符
            VStack(spacing: 16.rpx) {
                Image(systemName: "info.circle")
                    .foregroundColor(.gray.opacity(0.6))
                    .font(.system(size: 24))
                
                Text(Language.stone_info_detailed_not_available)
                    .font(.medium(16.rpx))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text(Language.stone_info_additional_characteristics)
                    .font(.regular(13.rpx))
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 32.rpx)
            .padding(.vertical, 40.rpx)
            .background(Color.white)
            .cornerRadius(12.rpx)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Stone Characteristics Section
struct StoneCharacteristicsSection: View {
    let stone: Stone
    
    // 检查是否有任何特征信息
    private var hasCharacteristics: Bool {
        return !(stone.description ?? "").isEmpty ||
               !(stone.usage ?? "").isEmpty ||
               (stone.healthRisks?.isEmpty == false) ||
               !(stone.originalVsFake ?? "").isEmpty ||
               !(stone.storage ?? "").isEmpty ||
               !(stone.cleaningTips ?? "").isEmpty
    }
    	
    var body: some View {
        // 只有当有特征信息时才显示这个部分
        if hasCharacteristics {
            VStack(alignment: .leading, spacing: 20.rpx) {
                // 标题
                Text(Language.stone_info_characteristics)
                    .font(.semibold(16.rpx))
                    .foregroundColor(.appText)
                
                VStack(alignment: .leading, spacing: 20.rpx) {
                    // 详细描述
                    if !(stone.description ?? "").isEmpty {
                        ExpandableCharacteristicItem(title: Language.text_description, content: stone.description ?? "")
                    }
                    
                    // 用途
                    if !(stone.usage ?? "").isEmpty {
                        ExpandableCharacteristicItem(title: Language.stone_usage, content: stone.usage ?? "")
                    }
                    
                    // 健康风险
                    if let risks = stone.healthRisks, !risks.isEmpty {
                        ExpandableCharacteristicItem(title: Language.stone_health_risks, content: risks)
                    }
                    
                    // 真伪鉴别
                    if !(stone.originalVsFake ?? "").isEmpty {
                        ExpandableCharacteristicItem(title: Language.stone_original_vs_fake, content: stone.originalVsFake ?? "")
                    }
                    
                    // 存储方法
                    if !(stone.storage ?? "").isEmpty {
                        ExpandableCharacteristicItem(title: Language.stone_storage, content: stone.storage ?? "")
                    }
                    
                    // 清洁技巧
                    if !(stone.cleaningTips ?? "").isEmpty {
                        ExpandableCharacteristicItem(title: Language.stone_cleaning_tips, content: stone.cleaningTips ?? "")
                    }
                }
            }
            .padding(16.rpx)
            .background(Color.white)
            .cornerRadius(12.rpx)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

struct CharacteristicItem: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6.rpx) {
            Text(title)
                .font(.medium(15.rpx))
                .foregroundColor(.black)
            
            Text(content)
                .font(.regular(13.rpx))
                .foregroundColor(.gray)
                .lineLimit(nil)
                .lineSpacing(2.rpx)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Stone Chemical Classification Section
struct StoneChemicalClassificationSection: View {
    let stone: Stone
    
    // 检查是否有任何化学分类信息
    private var hasClassificationInfo: Bool {
        return !(stone.chemicalFormula ?? "").isEmpty ||
               !(stone.chemicalClassification ?? "").isEmpty ||
               !(stone.crystalSystem ?? "").isEmpty ||
               !(stone.hardness ?? "").isEmpty ||
               !(stone.density ?? "").isEmpty
    }
    
    var body: some View {
        // 只有当有化学分类信息时才显示这个部分
        if hasClassificationInfo {
            VStack(alignment: .leading, spacing: 20.rpx) {
                // 标题
                Text(Language.stone_info_scientific_classification)
                    .font(.semibold(16.rpx))
                    .foregroundColor(.appText)
                
                VStack(alignment: .leading, spacing: 8.rpx) {
                    if !(stone.chemicalFormula ?? "").isEmpty {
                        ClassificationRow(label: Language.stone_chemical_formula, value: stone.chemicalFormula ?? "")
                    }
                    if !(stone.chemicalClassification ?? "").isEmpty {
                        ClassificationRow(label: Language.stone_chemical_classification, value: stone.chemicalClassification ?? "")
                    }
                    if !(stone.crystalSystem ?? "").isEmpty {
                        ClassificationRow(label: Language.stone_crystal_system, value: stone.crystalSystem ?? "")
                    }
                    if !(stone.hardness ?? "").isEmpty {
                        ClassificationRow(label: Language.stone_hardness, value: stone.hardness ?? "")
                    }
                    if !(stone.density ?? "").isEmpty {
                        ClassificationRow(label: Language.stone_density, value: stone.density ?? "")
                    }
                    
                    // 如果有化学元素详细信息，显示为备注
                    if !(stone.chemicalElements ?? "").isEmpty {
                        Divider()
                            .padding(.vertical, 8.rpx)
                        Text(Language.stone_chemical_elements)
                            .font(.semibold(16.rpx))
                            .foregroundColor(.appText)
                            .padding(.bottom, 4.rpx)
                        ExpandableText(text: stone.chemicalElements ?? "", lineLimit: 5)
                    }
                }
            }
            .padding(16.rpx)
            .background(Color.white)
            .cornerRadius(12.rpx)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

struct ClassificationRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12.rpx) {
            Text(label)
                .font(.regular(14.rpx))
                .foregroundColor(.appTextLight)
                .frame(width: 80.rpx, alignment: .leading)
            
            Text(value)
                .font(.regular(14.rpx))
                .foregroundColor(.appText)
            
            Spacer()
        }
        .padding(.vertical, 2.rpx)
    }
}

// MARK: - Expandable Components

// 可展开的特征项
struct ExpandableCharacteristicItem: View {
    let title: String
    let content: String
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.rpx) {
            Text(title)
                .font(.semibold(16.rpx))
                .foregroundColor(.appText)
            
            ZStack(alignment: .bottomTrailing) {
                Text(content)
                    .font(.regular(14.rpx))
                    .lineSpacing(4.rpx)
                    .foregroundColor(.appTextLight)
                    .lineLimit(isExpanded ? nil : 5)
                    .animation(.easeInOut, value: isExpanded)

                if !isExpanded && needsExpansion {
                    // "More >>" 按钮右下角悬挂显示
                    Button(action: {
                        isExpanded = true
                    }) {
                        HStack {
                            Text("...")
                                .font(.regular(12.rpx))
                                .lineSpacing(4.rpx)
                                .foregroundColor(.appTextLight)
                            Text(Language.stone_info_more)
                                .font(.regular(12.rpx))
                                .lineSpacing(4.rpx)
                                .foregroundColor(.primary)
                                .padding(.trailing, 2)
                        }
                        .background(Color.white)
                    }
                }
            }
        }
    }
    
        private var needsExpansion: Bool {
        // 如果文本长度超过200个字符，就需要展开功能
        return content.count > 200
    }
}

// 可展开的文本组件
struct ExpandableText: View {
    let text: String
    let lineLimit: Int
    @State private var isExpanded: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(text)
                .font(.regular(13.rpx))
                .lineSpacing(2.rpx)
                .foregroundColor(.gray.opacity(0.8))
                .lineLimit(isExpanded ? nil : lineLimit)
                .animation(.easeInOut, value: isExpanded)

            if !isExpanded && needsExpansion {
                // "More >>" 按钮右下角悬挂显示
                Button(action: {
                    isExpanded = true
                }) {
                    HStack {
                        Text("...")
                            .font(.regular(12.rpx))
                            .lineSpacing(2.rpx)
                            .foregroundColor(.gray.opacity(0.8))
                        Text(Language.stone_info_more)
                            .font(.regular(12.rpx))
                            .lineSpacing(2.rpx)
                            .foregroundColor(.primary)
                            .padding(.trailing, 2)
                    }
                    .background(Color.white)
                }
            }
        }
    }
    
    private var needsExpansion: Bool {
        // 如果文本长度超过150个字符，就需要展开功能
        return text.count > 150
    }
}
