import SwiftUI

// MARK: - 化学属性区域
struct StoneChemicalPropertiesSectionView: View {
    let stone: Stone
    
    var body: some View {
        StoneSectionContainerView(
            sectionTitle: Language.stone_chemical_properties,
            onMoreClick: nil,
            content: {
                VStack(alignment: .leading, spacing: 8.rpx) {
                    if !(stone.chemicalFormula ?? "").isEmpty {
                        PropertyRowView(label: Language.stone_chemical_formula, value: stone.chemicalFormula ?? "")
                    }
                    if !(stone.chemicalClassification ?? "").isEmpty {
                        PropertyRowView(label: Language.stone_chemical_classification, value: stone.chemicalClassification ?? "")
                    }
                    if !(stone.chemicalElements ?? "").isEmpty {
                        PropertyRowView(label: Language.stone_chemical_elements, value: stone.chemicalElements ?? "")
                    }
                    if !(stone.impurities ?? "").isEmpty {
                        PropertyRowView(label: Language.stone_impurities, value: stone.impurities ?? "")
                    }
                    if !(stone.variety ?? "").isEmpty {
                        PropertyRowView(label: Language.stone_variety, value: stone.variety ?? "")
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
}

// MARK: - 物理属性区域
struct StonePhysicalPropertiesSectionView: View {
    let stone: Stone
    
    var body: some View {
        StoneSectionContainerView(
            sectionTitle: Language.stone_physical_properties,
            onMoreClick: nil,
            content: {
                VStack(spacing: 12.rpx) {
                    VStack(spacing: 8.rpx) {
                        if !(stone.colors ?? "").isEmpty {
                            PropertyRowView(label: Language.stone_colors, value: stone.colors ?? "")
                        }
                        if !(stone.hardness ?? "").isEmpty {
                            PropertyRowView(label: Language.stone_hardness, value: stone.hardness ?? "")
                        }
                        if !(stone.crystalSystem ?? "").isEmpty {
                            PropertyRowView(label: Language.stone_crystal_system, value: stone.crystalSystem ?? "")
                        }
                        if !(stone.luster ?? "").isEmpty {
                            PropertyRowView(label: Language.stone_luster, value: stone.luster ?? "")
                        }
                        if !(stone.diaphaneity ?? "").isEmpty {
                            PropertyRowView(label: Language.stone_diaphaneity, value: stone.diaphaneity ?? "")
                        }
                        if !(stone.magnetism ?? "").isEmpty {
                            PropertyRowView(label: Language.stone_magnetism, value: stone.magnetism ?? "")
                        }
                        if !(stone.streak ?? "").isEmpty {
                            PropertyRowView(label: Language.stone_streak, value: stone.streak ?? "")
                        }
                        if !(stone.tenacity ?? "").isEmpty {
                            PropertyRowView(label: Language.stone_tenacity, value: stone.tenacity ?? "")
                        }
                        if !(stone.cleavage ?? "").isEmpty {
                            PropertyRowView(label: Language.stone_cleavage, value: stone.cleavage ?? "")
                        }
                        if !(stone.facture ?? "").isEmpty {
                            PropertyRowView(label: Language.stone_fracture, value: stone.facture ?? "")
                        }
                        if !(stone.density ?? "").isEmpty {
                            PropertyRowView(label: Language.stone_density, value: stone.density ?? "")
                        }
                    }
                    
                    // 耐久性评级
                    VStack(alignment: .leading, spacing: 8.rpx) {
                        Text(Language.stone_durability_rating)
                            .font(.semibold(16.rpx))
                            .foregroundColor(.primary)
                        
                        DurabilityRatingView(label: Language.stone_scratch_resistance, rating: stone.scratchValue ?? 0)
                        DurabilityRatingView(label: Language.stone_toughness, rating: stone.toughnessValue ?? 0)
                        DurabilityRatingView(label: Language.stone_stability, rating: stone.stabilityValue ?? 0)
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
}

// MARK: - 护理说明区域
struct StoneCareInstructionsSectionView: View {
    let stone: Stone
    
    var body: some View {
        StoneSectionContainerView(
            sectionTitle: Language.stone_care_instructions,
            onMoreClick: nil,
            content: {
                VStack(alignment: .leading, spacing: 8.rpx) {
                    if !(stone.storage ?? "").isEmpty {
                        CareItemView(title: Language.stone_storage, description: stone.storage ?? "")
                    }
                    if !(stone.light ?? "").isEmpty {
                        CareItemView(title: Language.stone_light, description: stone.light ?? "")
                    }
                    if !(stone.temperature ?? "").isEmpty {
                        CareItemView(title: Language.stone_temperature, description: stone.temperature ?? "")
                    }
                    if !(stone.cleaningTips ?? "").isEmpty {
                        CareItemView(title: Language.stone_cleaning_tips, description: stone.cleaningTips ?? "")
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
}

// MARK: - 价格信息区域
struct StonePriceSectionView: View {
    let stone: Stone
    
    private var caratPriceRange: String? {
        guard let priceFrom = stone.pricePerCaratFrom else { return nil }
        if let priceTo = stone.pricePerCaratTo {
            return "$\(String(format: "%.2f", priceFrom)) - $\(String(format: "%.2f", priceTo))"
        } else {
            return "$\(String(format: "%.2f", priceFrom))"
        }
    }
    
    private var poundPriceRange: String? {
        guard let priceFrom = stone.pricePerPoundFrom else { return nil }
        if let priceTo = stone.pricePerPoundTo {
            return "$\(String(format: "%.2f", priceFrom)) - $\(String(format: "%.2f", priceTo))"
        } else {
            return "$\(String(format: "%.2f", priceFrom))"
        }
    }
    
    var body: some View {
        StoneSectionContainerView(
            sectionTitle: Language.stone_price_information,
            onMoreClick: nil,
            content: {
                VStack(alignment: .leading, spacing: 8.rpx) {
                    if let caratPrice = caratPriceRange {
                        PropertyRowView(label: Language.stone_per_carat, value: caratPrice)
                    }
                    
                    if let poundPrice = poundPriceRange {
                        PropertyRowView(label: Language.stone_per_pound, value: poundPrice)
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
}

// MARK: - 形而上学属性区域
struct StoneMetaphysicalSectionView: View {
    let stone: Stone
    
    var body: some View {
        StoneSectionContainerView(
            sectionTitle: Language.stone_metaphysical_properties,
            onMoreClick: nil,
            content: {
                VStack(alignment: .leading, spacing: 16.rpx) {
                    // 脉轮
                    VStack(alignment: .leading, spacing: 8.rpx) {
                        if !(stone.chakraRoot ?? "").isEmpty {
                            ChakraItemView(name: Language.stone_chakra_root, description: stone.chakraRoot ?? "", color: Color(red: 0.898, green: 0.243, blue: 0.243))
                        }
                        if !(stone.chakraSacral ?? "").isEmpty {
                            ChakraItemView(name: Language.stone_chakra_sacral, description: stone.chakraSacral ?? "", color: Color(red: 1.0, green: 0.549, blue: 0.0))
                        }
                        if !(stone.chakraSolar ?? "").isEmpty {
                            ChakraItemView(name: Language.stone_chakra_solar, description: stone.chakraSolar ?? "", color: Color(red: 1.0, green: 0.843, blue: 0.0))
                        }
                        if !(stone.chakraHeart ?? "").isEmpty {
                            ChakraItemView(name: Language.stone_chakra_heart, description: stone.chakraHeart ?? "", color: Color(red: 0.220, green: 0.631, blue: 0.412))
                        }
                        if !(stone.chakraThroat ?? "").isEmpty {
                            ChakraItemView(name: Language.stone_chakra_throat, description: stone.chakraThroat ?? "", color: Color(red: 0.196, green: 0.510, blue: 0.808))
                        }
                        if !(stone.chakraEye ?? "").isEmpty {
                            ChakraItemView(name: Language.stone_chakra_third_eye, description: stone.chakraEye ?? "", color: Color(red: 0.333, green: 0.235, blue: 0.604))
                        }
                        if !(stone.chakraCrown ?? "").isEmpty {
                            ChakraItemView(name: Language.stone_chakra_crown, description: stone.chakraCrown ?? "", color: Color(red: 0.502, green: 0.353, blue: 0.835))
                        }
                    }
                    
                    if hasQualityProperties {
                        // 品质属性
                        VStack(spacing: 8.rpx) {
                            if !(stone.qualityTranquillity ?? "").isEmpty {
                                QualityItemView(quality: Language.stone_quality_tranquillity, description: stone.qualityTranquillity ?? "")
                            }
                            if !(stone.qualityGrounding ?? "").isEmpty {
                                QualityItemView(quality: Language.stone_quality_grounding, description: stone.qualityGrounding ?? "")
                            }
                            if !(stone.qualityProtection ?? "").isEmpty {
                                QualityItemView(quality: Language.stone_quality_protection, description: stone.qualityProtection ?? "")
                            }
                            if !(stone.qualityHealing ?? "").isEmpty {
                                QualityItemView(quality: Language.stone_quality_healing, description: stone.qualityHealing ?? "")
                            }
                            if !(stone.qualityClarity ?? "").isEmpty {
                                QualityItemView(quality: Language.stone_quality_clarity, description: stone.qualityClarity ?? "")
                            }
                            if !(stone.qualitySpiritual ?? "").isEmpty {
                                QualityItemView(quality: Language.stone_quality_spiritual, description: stone.qualitySpiritual ?? "")
                            }
                            if !(stone.qualityEnergy ?? "").isEmpty {
                                QualityItemView(quality: Language.stone_quality_energy, description: stone.qualityEnergy ?? "")
                            }
                            if !(stone.qualityProsperity ?? "").isEmpty {
                                QualityItemView(quality: Language.stone_quality_prosperity, description: stone.qualityProsperity ?? "")
                            }
                            if !(stone.qualityBalance ?? "").isEmpty {
                                QualityItemView(quality: Language.stone_quality_balance, description: stone.qualityBalance ?? "")
                            }
                            if !(stone.qualityLove ?? "").isEmpty {
                                QualityItemView(quality: Language.stone_quality_love, description: stone.qualityLove ?? "")
                            }
                        }
                    }
                    
                    if hasCareProperties {
                        // 护理方法
                        VStack(spacing: 8.rpx) {
                            if stone.enhancing != nil {
                                CareItemView(title: Language.stone_enhancing, description: stone.enhancing!)
                            }
                            if stone.charging != nil {
                                CareItemView(title: Language.stone_charging, description: stone.charging!)
                            }
                            if stone.cleansing != nil {
                                CareItemView(title: Language.stone_cleansing, description: stone.cleansing!)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
    
    private var hasQualityProperties: Bool {
        return !(stone.qualityTranquillity ?? "").isEmpty ||
               !(stone.qualityGrounding ?? "").isEmpty ||
               !(stone.qualityProtection ?? "").isEmpty ||
               !(stone.qualityHealing ?? "").isEmpty ||
               !(stone.qualityClarity ?? "").isEmpty ||
               !(stone.qualitySpiritual ?? "").isEmpty ||
               !(stone.qualityEnergy ?? "").isEmpty ||
               !(stone.qualityProsperity ?? "").isEmpty ||
               !(stone.qualityBalance ?? "").isEmpty ||
               !(stone.qualityLove ?? "").isEmpty
    }
    
    private var hasCareProperties: Bool {
        return !(stone.enhancing ?? "").isEmpty ||
               !(stone.charging ?? "").isEmpty ||
               !(stone.cleansing ?? "").isEmpty
    }
}

// MARK: - FAQ区域
struct StoneFAQSectionView: View {
    let stone: Stone
    
    var body: some View {
        StoneSectionContainerView(
            sectionTitle: "常见问题",
            onMoreClick: nil,
            content: {
                VStack(spacing: 0) {
                    ForEach((stone.faqs ?? []).indices, id: \.self) { index in
                        let faq = (stone.faqs ?? [])[index]
                        FAQItemView(question: faq.question ?? "", answer: faq.answer ?? "")
                        
                        if index < (stone.faqs ?? []).count - 1 {
                            Divider()
                                .background(Color.gray.opacity(0.2))
                                .padding(.vertical, 4.rpx)
                        }
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
}

// MARK: - 用途和安全信息区域
struct StoneUsageSectionView: View {
    let stone: Stone
    
    var body: some View {
        StoneSectionContainerView(
            sectionTitle: "用途与安全信息",
            onMoreClick: nil,
            content: {
                VStack(spacing: 12.rpx) {
                    if !(stone.usage ?? "").isEmpty {
                        CareItemView(title: "用途", description: stone.usage ?? "")
                    }
                    if stone.healthRisks != nil {
                        CareItemView(title: "健康风险", description: stone.healthRisks!)
                    }
                    if !(stone.originalVsFake ?? "").isEmpty {
                        CareItemView(title: "真伪鉴别", description: stone.originalVsFake ?? "")
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
}

// MARK: - 辅助组件

struct PropertyRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.regular(14.rpx))
                .foregroundColor(.appTextLight)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(.medium(14.rpx))
                .foregroundColor(.appText)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 4.rpx)
    }
}

struct DurabilityRatingView: View {
    let label: String
    let rating: Int
    
    var body: some View {
        HStack {
            Text(label)
                .font(.regular(14.rpx))
                .foregroundColor(.appTextLight)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 2.rpx) {
                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2.rpx)
                        .fill(index < rating ? Color.primary : Color.gray.opacity(0.3))
                        .frame(width: 16.rpx, height: 16.rpx)
                }
            }
        }
        .padding(.vertical, 4.rpx)
    }
}

struct CareItemView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.rpx) {
            Text(title)
                .font(.medium(14.rpx))
                .foregroundColor(.appText)
            
            Text(description)
                .font(.regular(14.rpx))
                .foregroundColor(.appTextLight)
                .lineSpacing(4.rpx)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ChakraItemView: View {
    let name: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 8.rpx) {
            Circle()
                .fill(color)
                .frame(width: 12.rpx, height: 12.rpx)
                .padding(.top, 2.rpx)
            
            VStack(alignment: .leading, spacing: 2.rpx) {
                Text(name)
                    .font(.medium(14.rpx))
                    .foregroundColor(.appText)
                
                Text(description)
                    .font(.regular(12.rpx))
                    .foregroundColor(.appTextLight)
                    .lineSpacing(2.rpx)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4.rpx)
    }
}

struct QualityItemView: View {
    let quality: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.rpx) {
            Text(quality)
                .font(.medium(14.rpx))
                .foregroundColor(.primary)
            
            Text(description)
                .font(.regular(14.rpx))
                .foregroundColor(.appTextLight)
                .lineSpacing(4.rpx)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4.rpx)
    }
}

struct FAQItemView: View {
    let question: String
    let answer: String
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 使用整个区域作为可点击区域
            HStack {
                Text(question)
                    .font(.medium(14.rpx))
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12.rpx))
                    .foregroundColor(.appTextLight)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
            }
            .padding(.vertical, 12.rpx)
            .contentShape(Rectangle()) // 确保整个区域都可以点击
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    isExpanded.toggle()
                }
            }
            
            VStack(spacing: 0) {
                if isExpanded {
                    Text(answer)
                        .font(.regular(14.rpx))
                        .foregroundColor(.appTextLight)
                        .lineSpacing(4.rpx)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4.rpx)
                        .padding(.bottom, 12.rpx)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)).combined(with: .offset(y: -10)),
                            removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)).combined(with: .offset(y: -5))
                        ))
                }
            }
            .clipped()
        }
        .background(
            RoundedRectangle(cornerRadius: 8.rpx)
                .fill(isExpanded ? Color.gray.opacity(0.05) : Color.clear)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isExpanded)
        )
    }
}
