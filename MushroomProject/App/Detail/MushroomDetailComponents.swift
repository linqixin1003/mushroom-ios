import SwiftUI

// MARK: - 化学属性区域
struct MushroomChemicalPropertiesSectionView: View {
    let mushroom: Mushroom
    
    var body: some View {
        MushroomSectionContainerView(
            sectionTitle: Language.mushroom_chemical_properties,
            onMoreClick: nil,
            content: {
                VStack(alignment: .leading, spacing: 8.rpx) {
                    if !(mushroom.chemicalFormula ?? "").isEmpty {
                        PropertyRowView(label: Language.mushroom_chemical_formula, value: mushroom.chemicalFormula ?? "")
                    }
                    if !(mushroom.chemicalClassification ?? "").isEmpty {
                        PropertyRowView(label: Language.mushroom_chemical_classification, value: mushroom.chemicalClassification ?? "")
                    }
                    if !(mushroom.chemicalElements ?? "").isEmpty {
                        PropertyRowView(label: Language.mushroom_chemical_elements, value: mushroom.chemicalElements ?? "")
                    }
                    if !(mushroom.impurities ?? "").isEmpty {
                        PropertyRowView(label: Language.mushroom_impurities, value: mushroom.impurities ?? "")
                    }
                    if !(mushroom.variety ?? "").isEmpty {
                        PropertyRowView(label: Language.mushroom_variety, value: mushroom.variety ?? "")
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
}

// MARK: - 物理属性区域
struct MushroomPhysicalPropertiesSectionView: View {
    let mushroom: Mushroom
    
    var body: some View {
        MushroomSectionContainerView(
            sectionTitle: Language.mushroom_physical_properties,
            onMoreClick: nil,
            content: {
                VStack(spacing: 12.rpx) {
                    VStack(spacing: 8.rpx) {
                        if !(mushroom.colors ?? "").isEmpty {
                            PropertyRowView(label: Language.mushroom_colors, value: mushroom.colors ?? "")
                        }
                        if !(mushroom.hardness ?? "").isEmpty {
                            PropertyRowView(label: Language.mushroom_hardness, value: mushroom.hardness ?? "")
                        }
                        if !(mushroom.crystalSystem ?? "").isEmpty {
                            PropertyRowView(label: Language.mushroom_crystal_system, value: mushroom.crystalSystem ?? "")
                        }
                        if !(mushroom.luster ?? "").isEmpty {
                            PropertyRowView(label: Language.mushroom_luster, value: mushroom.luster ?? "")
                        }
                        if !(mushroom.diaphaneity ?? "").isEmpty {
                            PropertyRowView(label: Language.mushroom_diaphaneity, value: mushroom.diaphaneity ?? "")
                        }
                        if !(mushroom.magnetism ?? "").isEmpty {
                            PropertyRowView(label: Language.mushroom_magnetism, value: mushroom.magnetism ?? "")
                        }
                        if !(mushroom.streak ?? "").isEmpty {
                            PropertyRowView(label: Language.mushroom_streak, value: mushroom.streak ?? "")
                        }
                        if !(mushroom.tenacity ?? "").isEmpty {
                            PropertyRowView(label: Language.mushroom_tenacity, value: mushroom.tenacity ?? "")
                        }
                        if !(mushroom.cleavage ?? "").isEmpty {
                            PropertyRowView(label: Language.mushroom_cleavage, value: mushroom.cleavage ?? "")
                        }
                        if !(mushroom.facture ?? "").isEmpty {
                            PropertyRowView(label: Language.mushroom_fracture, value: mushroom.facture ?? "")
                        }
                        if !(mushroom.density ?? "").isEmpty {
                            PropertyRowView(label: Language.mushroom_density, value: mushroom.density ?? "")
                        }
                    }
                    
                    // 耐久性评级
                    VStack(alignment: .leading, spacing: 8.rpx) {
                        Text(Language.mushroom_durability_rating)
                            .font(.semibold(16.rpx))
                            .foregroundColor(.primary)
                        
                        DurabilityRatingView(label: Language.mushroom_scratch_resistance, rating: mushroom.scratchValue ?? 0)
                        DurabilityRatingView(label: Language.mushroom_toughness, rating: mushroom.toughnessValue ?? 0)
                        DurabilityRatingView(label: Language.mushroom_stability, rating: mushroom.stabilityValue ?? 0)
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
}

// MARK: - 护理说明区域
struct MushroomCareInstructionsSectionView: View {
    let mushroom: Mushroom
    
    var body: some View {
        MushroomSectionContainerView(
            sectionTitle: Language.mushroom_care_instructions,
            onMoreClick: nil,
            content: {
                VStack(alignment: .leading, spacing: 8.rpx) {
                    if !(mushroom.storage ?? "").isEmpty {
                        CareItemView(title: Language.mushroom_storage, description: mushroom.storage ?? "")
                    }
                    if !(mushroom.light ?? "").isEmpty {
                        CareItemView(title: Language.mushroom_light, description: mushroom.light ?? "")
                    }
                    if !(mushroom.temperature ?? "").isEmpty {
                        CareItemView(title: Language.mushroom_temperature, description: mushroom.temperature ?? "")
                    }
                    if !(mushroom.cleaningTips ?? "").isEmpty {
                        CareItemView(title: Language.mushroom_cleaning_tips, description: mushroom.cleaningTips ?? "")
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
}

// MARK: - 价格信息区域
struct MushroomPriceSectionView: View {
    let mushroom: Mushroom
    
    private var caratPriceRange: String? {
        guard let priceFrom = mushroom.pricePerCaratFrom else { return nil }
        if let priceTo = mushroom.pricePerCaratTo {
            return "$\(String(format: "%.2f", priceFrom)) - $\(String(format: "%.2f", priceTo))"
        } else {
            return "$\(String(format: "%.2f", priceFrom))"
        }
    }
    
    private var poundPriceRange: String? {
        guard let priceFrom = mushroom.pricePerPoundFrom else { return nil }
        if let priceTo = mushroom.pricePerPoundTo {
            return "$\(String(format: "%.2f", priceFrom)) - $\(String(format: "%.2f", priceTo))"
        } else {
            return "$\(String(format: "%.2f", priceFrom))"
        }
    }
    
    var body: some View {
        MushroomSectionContainerView(
            sectionTitle: Language.mushroom_price_information,
            onMoreClick: nil,
            content: {
                VStack(alignment: .leading, spacing: 8.rpx) {
                    if let caratPrice = caratPriceRange {
                        PropertyRowView(label: Language.mushroom_per_carat, value: caratPrice)
                    }
                    
                    if let poundPrice = poundPriceRange {
                        PropertyRowView(label: Language.mushroom_per_pound, value: poundPrice)
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
}

// MARK: - 形而上学属性区域
struct MushroomMetaphysicalSectionView: View {
    let mushroom: Mushroom
    
    var body: some View {
        MushroomSectionContainerView(
            sectionTitle: Language.mushroom_metaphysical_properties,
            onMoreClick: nil,
            content: {
                VStack(alignment: .leading, spacing: 16.rpx) {
                    // 脉轮
                    VStack(alignment: .leading, spacing: 8.rpx) {
                        if !(mushroom.chakraRoot ?? "").isEmpty {
                            ChakraItemView(name: Language.mushroom_chakra_root, description: mushroom.chakraRoot ?? "", color: Color(red: 0.898, green: 0.243, blue: 0.243))
                        }
                        if !(mushroom.chakraSacral ?? "").isEmpty {
                            ChakraItemView(name: Language.mushroom_chakra_sacral, description: mushroom.chakraSacral ?? "", color: Color(red: 1.0, green: 0.549, blue: 0.0))
                        }
                        if !(mushroom.chakraSolar ?? "").isEmpty {
                            ChakraItemView(name: Language.mushroom_chakra_solar, description: mushroom.chakraSolar ?? "", color: Color(red: 1.0, green: 0.843, blue: 0.0))
                        }
                        if !(mushroom.chakraHeart ?? "").isEmpty {
                            ChakraItemView(name: Language.mushroom_chakra_heart, description: mushroom.chakraHeart ?? "", color: Color(red: 0.220, green: 0.631, blue: 0.412))
                        }
                        if !(mushroom.chakraThroat ?? "").isEmpty {
                            ChakraItemView(name: Language.mushroom_chakra_throat, description: mushroom.chakraThroat ?? "", color: Color(red: 0.196, green: 0.510, blue: 0.808))
                        }
                        if !(mushroom.chakraEye ?? "").isEmpty {
                            ChakraItemView(name: Language.mushroom_chakra_third_eye, description: mushroom.chakraEye ?? "", color: Color(red: 0.333, green: 0.235, blue: 0.604))
                        }
                        if !(mushroom.chakraCrown ?? "").isEmpty {
                            ChakraItemView(name: Language.mushroom_chakra_crown, description: mushroom.chakraCrown ?? "", color: Color(red: 0.502, green: 0.353, blue: 0.835))
                        }
                    }
                    
                    if hasQualityProperties {
                        // 品质属性
                        VStack(spacing: 8.rpx) {
                            if !(mushroom.qualityTranquillity ?? "").isEmpty {
                                QualityItemView(quality: Language.mushroom_quality_tranquillity, description: mushroom.qualityTranquillity ?? "")
                            }
                            if !(mushroom.qualityGrounding ?? "").isEmpty {
                                QualityItemView(quality: Language.mushroom_quality_grounding, description: mushroom.qualityGrounding ?? "")
                            }
                            if !(mushroom.qualityProtection ?? "").isEmpty {
                                QualityItemView(quality: Language.mushroom_quality_protection, description: mushroom.qualityProtection ?? "")
                            }
                            if !(mushroom.qualityHealing ?? "").isEmpty {
                                QualityItemView(quality: Language.mushroom_quality_healing, description: mushroom.qualityHealing ?? "")
                            }
                            if !(mushroom.qualityClarity ?? "").isEmpty {
                                QualityItemView(quality: Language.mushroom_quality_clarity, description: mushroom.qualityClarity ?? "")
                            }
                            if !(mushroom.qualitySpiritual ?? "").isEmpty {
                                QualityItemView(quality: Language.mushroom_quality_spiritual, description: mushroom.qualitySpiritual ?? "")
                            }
                            if !(mushroom.qualityEnergy ?? "").isEmpty {
                                QualityItemView(quality: Language.mushroom_quality_energy, description: mushroom.qualityEnergy ?? "")
                            }
                            if !(mushroom.qualityProsperity ?? "").isEmpty {
                                QualityItemView(quality: Language.mushroom_quality_prosperity, description: mushroom.qualityProsperity ?? "")
                            }
                            if !(mushroom.qualityBalance ?? "").isEmpty {
                                QualityItemView(quality: Language.mushroom_quality_balance, description: mushroom.qualityBalance ?? "")
                            }
                            if !(mushroom.qualityLove ?? "").isEmpty {
                                QualityItemView(quality: Language.mushroom_quality_love, description: mushroom.qualityLove ?? "")
                            }
                        }
                    }
                    
                    if hasCareProperties {
                        // 护理方法
                        VStack(spacing: 8.rpx) {
                            if mushroom.enhancing != nil {
                                CareItemView(title: Language.mushroom_enhancing, description: mushroom.enhancing!)
                            }
                            if mushroom.charging != nil {
                                CareItemView(title: Language.mushroom_charging, description: mushroom.charging!)
                            }
                            if mushroom.cleansing != nil {
                                CareItemView(title: Language.mushroom_cleansing, description: mushroom.cleansing!)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20.rpx)
            }
        )
    }
    
    private var hasQualityProperties: Bool {
        return !(mushroom.qualityTranquillity ?? "").isEmpty ||
               !(mushroom.qualityGrounding ?? "").isEmpty ||
               !(mushroom.qualityProtection ?? "").isEmpty ||
               !(mushroom.qualityHealing ?? "").isEmpty ||
               !(mushroom.qualityClarity ?? "").isEmpty ||
               !(mushroom.qualitySpiritual ?? "").isEmpty ||
               !(mushroom.qualityEnergy ?? "").isEmpty ||
               !(mushroom.qualityProsperity ?? "").isEmpty ||
               !(mushroom.qualityBalance ?? "").isEmpty ||
               !(mushroom.qualityLove ?? "").isEmpty
    }
    
    private var hasCareProperties: Bool {
        return !(mushroom.enhancing ?? "").isEmpty ||
               !(mushroom.charging ?? "").isEmpty ||
               !(mushroom.cleansing ?? "").isEmpty
    }
}

// MARK: - FAQ区域
struct MushroomFAQSectionView: View {
    let mushroom: Mushroom
    
    var body: some View {
        MushroomSectionContainerView(
            sectionTitle: "常见问题",
            onMoreClick: nil,
            content: {
                VStack(spacing: 0) {
                    ForEach((mushroom.faqs ?? []).indices, id: \.self) { index in
                        let faq = (mushroom.faqs ?? [])[index]
                        FAQItemView(question: faq.question ?? "", answer: faq.answer ?? "")
                        
                        if index < (mushroom.faqs ?? []).count - 1 {
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
struct MushroomUsageSectionView: View {
    let mushroom: Mushroom
    
    var body: some View {
        MushroomSectionContainerView(
            sectionTitle: "用途与安全信息",
            onMoreClick: nil,
            content: {
                VStack(spacing: 12.rpx) {
                    if !(mushroom.usage ?? "").isEmpty {
                        CareItemView(title: "用途", description: mushroom.usage ?? "")
                    }
                    if mushroom.healthRisks != nil {
                        CareItemView(title: "健康风险", description: mushroom.healthRisks!)
                    }
                    if !(mushroom.originalVsFake ?? "").isEmpty {
                        CareItemView(title: "真伪鉴别", description: mushroom.originalVsFake ?? "")
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
