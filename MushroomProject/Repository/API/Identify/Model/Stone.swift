import Foundation

/**
 * Stone detailed information model
 */
struct Stone: Codable {
    let id: String
    let name: String
    let image: String?
    let description: String?
    let healthRisks: String?
    let usage: String?
    let originalVsFake: String?
    let commonNames: String?
    let chemicalFormula: String?
    let chemicalClassification: String?
    let chemicalElements: String?
    let impurities: String?
    let variety: String?
    let colors: String?
    let hardness: String?
    let crystalSystem: String?
    let luster: String?
    let diaphaneity: String?
    let magnetism: String?
    let streak: String?
    let tenacity: String?
    let cleavage: String?
    let facture: String?
    let density: String?
    let durability: String?
    let scratchResistance: String?
    let toughness: String?
    let stability: String?
    let scratchValue: Int?
    let toughnessValue: Int?
    let stabilityValue: Int?
    let storage: String?
    let light: String?
    let temperature: String?
    let cleaningTips: String?
    let enhancing: String?
    let charging: String?
    let cleansing: String?
    let chakraRoot: String?
    let chakraSacral: String?
    let chakraSolar: String?
    let chakraHeart: String?
    let chakraThroat: String?
    let chakraEye: String?
    let chakraCrown: String?
    var showMetaphysical: Bool?
    let qualitySpiritual: String?
    let qualityTranquillity: String?
    let qualityGrounding: String?
    let qualityEnergy: String?
    let qualityProtection: String?
    let qualityProsperity: String?
    let qualityHealing: String?
    let qualityBalance: String?
    let qualityClarity: String?
    let qualityLove: String?
    let tags: [String]?
    let locations: [StoneLocation]?
    let photos: [StonePhoto]?
    let videos: [String]?
    let faqs: [StoneFAQ]?
    let userCollection: String?
    var isFavorite: Bool
    let zodiacs: [String]?
    let articles: [String]?
    let usersLocations: [String]?
    let workWithList: [String]?
    let jewelery: [String]?
    let pricePerCaratFrom: Double?
    let pricePerCaratTo: Double?
    let pricePerPoundFrom: Double?
    let pricePerPoundTo: Double?
    let originalPost: String?
    let workWith: [String]?
    let imageUrl: String?

    init(
        id: String,
        name: String,
        image: String? = nil,
        description: String? = nil,
        healthRisks: String? = nil,
        usage: String? = nil,
        originalVsFake: String? = nil,
        commonNames: String? = nil,
        chemicalFormula: String? = nil,
        chemicalClassification: String? = nil,
        chemicalElements: String? = nil,
        impurities: String? = nil,
        variety: String? = nil,
        colors: String? = nil,
        hardness: String? = nil,
        crystalSystem: String? = nil,
        luster: String? = nil,
        diaphaneity: String? = nil,
        magnetism: String? = nil,
        streak: String? = nil,
        tenacity: String? = nil,
        cleavage: String? = nil,
        facture: String? = nil,
        density: String? = nil,
        durability: String? = nil,
        scratchResistance: String? = nil,
        toughness: String? = nil,
        stability: String? = nil,
        scratchValue: Int? = nil,
        toughnessValue: Int? = nil,
        stabilityValue: Int? = nil,
        storage: String? = nil,
        light: String? = nil,
        temperature: String? = nil,
        cleaningTips: String? = nil,
        enhancing: String? = nil,
        charging: String? = nil,
        cleansing: String? = nil,
        chakraRoot: String? = nil,
        chakraSacral: String? = nil,
        chakraSolar: String? = nil,
        chakraHeart: String? = nil,
        chakraThroat: String? = nil,
        chakraEye: String? = nil,
        chakraCrown: String? = nil,
        showMetaphysical: Bool? = nil,
        qualitySpiritual: String? = nil,
        qualityTranquillity: String? = nil,
        qualityGrounding: String? = nil,
        qualityEnergy: String? = nil,
        qualityProtection: String? = nil,
        qualityProsperity: String? = nil,
        qualityHealing: String? = nil,
        qualityBalance: String? = nil,
        qualityClarity: String? = nil,
        qualityLove: String? = nil,
        tags: [String]? = nil,
        locations: [StoneLocation]? = nil,
        photos: [StonePhoto]? = nil,
        videos: [String]? = nil,
        faqs: [StoneFAQ]? = nil,
        userCollection: String? = nil,
        isFavorite: Bool = false,
        zodiacs: [String]? = nil,
        articles: [String]? = nil,
        usersLocations: [String]? = nil,
        workWithList: [String]? = nil,
        jewelery: [String]? = nil,
        pricePerCaratFrom: Double? = nil,
        pricePerCaratTo: Double? = nil,
        pricePerPoundFrom: Double? = nil,
        pricePerPoundTo: Double? = nil,
        originalPost: String? = nil,
        workWith: [String]? = nil,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.description = description
        self.healthRisks = healthRisks
        self.usage = usage
        self.originalVsFake = originalVsFake
        self.commonNames = commonNames
        self.chemicalFormula = chemicalFormula
        self.chemicalClassification = chemicalClassification
        self.chemicalElements = chemicalElements
        self.impurities = impurities
        self.variety = variety
        self.colors = colors
        self.hardness = hardness
        self.crystalSystem = crystalSystem
        self.luster = luster
        self.diaphaneity = diaphaneity
        self.magnetism = magnetism
        self.streak = streak
        self.tenacity = tenacity
        self.cleavage = cleavage
        self.facture = facture
        self.density = density
        self.durability = durability
        self.scratchResistance = scratchResistance
        self.toughness = toughness
        self.stability = stability
        self.scratchValue = scratchValue
        self.toughnessValue = toughnessValue
        self.stabilityValue = stabilityValue
        self.storage = storage
        self.light = light
        self.temperature = temperature
        self.cleaningTips = cleaningTips
        self.enhancing = enhancing
        self.charging = charging
        self.cleansing = cleansing
        self.chakraRoot = chakraRoot
        self.chakraSacral = chakraSacral
        self.chakraSolar = chakraSolar
        self.chakraHeart = chakraHeart
        self.chakraThroat = chakraThroat
        self.chakraEye = chakraEye
        self.chakraCrown = chakraCrown
        self.showMetaphysical = showMetaphysical
        self.qualitySpiritual = qualitySpiritual
        self.qualityTranquillity = qualityTranquillity
        self.qualityGrounding = qualityGrounding
        self.qualityEnergy = qualityEnergy
        self.qualityProtection = qualityProtection
        self.qualityProsperity = qualityProsperity
        self.qualityHealing = qualityHealing
        self.qualityBalance = qualityBalance
        self.qualityClarity = qualityClarity
        self.qualityLove = qualityLove
        self.tags = tags
        self.locations = locations
        self.photos = photos
        self.videos = videos
        self.faqs = faqs
        self.userCollection = userCollection
        self.isFavorite = isFavorite
        self.zodiacs = zodiacs
        self.articles = articles
        self.usersLocations = usersLocations
        self.workWithList = workWithList
        self.jewelery = jewelery
        self.pricePerCaratFrom = pricePerCaratFrom
        self.pricePerCaratTo = pricePerCaratTo
        self.pricePerPoundFrom = pricePerPoundFrom
        self.pricePerPoundTo = pricePerPoundTo
        self.originalPost = originalPost
        self.workWith = workWith
        self.imageUrl = imageUrl
    }

    // 为了兼容性，添加一个计算属性来获取images
    var images: [String] {
        guard let photos = photos else { return [] }
        return photos.compactMap { $0.url }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case description
        case healthRisks = "health_risks"
        case usage
        case originalVsFake = "original_vs_fake"
        case commonNames = "common_names"
        case chemicalFormula = "chemical_formula"
        case chemicalClassification = "chemical_classification"
        case chemicalElements = "chemical_elements"
        case impurities
        case variety
        case colors
        case hardness
        case crystalSystem = "crystal_system"
        case luster
        case diaphaneity
        case magnetism
        case streak
        case tenacity
        case cleavage
        case facture
        case density
        case durability
        case scratchResistance = "scratch_resistance"
        case toughness
        case stability
        case scratchValue = "scratch_value"
        case toughnessValue = "toughness_value"
        case stabilityValue = "stability_value"
        case storage
        case light
        case temperature
        case cleaningTips = "cleaning_tips"
        case enhancing
        case charging
        case cleansing
        case chakraRoot = "chakra_root"
        case chakraSacral = "chakra_sacral"
        case chakraSolar = "chakra_solar"
        case chakraHeart = "chakra_heart"
        case chakraThroat = "chakra_throat"
        case chakraEye = "chakra_eye"
        case chakraCrown = "chakra_crown"
        case showMetaphysical = "show_metaphysical"
        case qualitySpiritual = "quality_spiritual"
        case qualityTranquillity = "quality_tranquillity"
        case qualityGrounding = "quality_grounding"
        case qualityEnergy = "quality_energy"
        case qualityProtection = "quality_protection"
        case qualityProsperity = "quality_prosperity"
        case qualityHealing = "quality_healing"
        case qualityBalance = "quality_balance"
        case qualityClarity = "quality_clarity"
        case qualityLove = "quality_love"
        case tags
        case locations
        case photos
        case videos
        case faqs
        case userCollection = "user_collection"
        case isFavorite = "is_favorite"
        case zodiacs
        case articles
        case usersLocations = "users_locations"
        case workWithList = "work_with_list"
        case jewelery
        case pricePerCaratFrom = "price_per_carat_from"
        case pricePerCaratTo = "price_per_carat_to"
        case pricePerPoundFrom = "price_per_pound_from"
        case pricePerPoundTo = "price_per_pound_to"
        case originalPost = "original_post"
        case workWith = "work_with"
        case imageUrl = "image_url"
    }

    func toSimpleStone() -> SimpleStone {
        let mappedTags: [StoneTag] = (self.tags ?? []).map { tagName in
            StoneTag(id: 0, name: tagName, slug: tagName)
        }
        return SimpleStone(
            id: self.id,
            name: self.name ?? "",
            description: self.description ?? "",
            photoUrl: self.image ?? "",
            chemicalFormula: self.chemicalFormula ?? "",
            colors: self.colors ?? "",
            hardness: self.hardness ?? "",
            tags: mappedTags
        )
    }
}

struct StoneLocation: Codable {
    let latitude: String?
    let longitude: String?
    let name: String?
}

struct StonePhoto: Codable {
    let id: Int?
    let stone: String?
    let image: String?
    let isPrimary: Bool?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case stone
        case image
        case isPrimary = "is_primary"
        case url
    }
}

struct StoneFAQ: Codable {
    let question: String?
    let answer: String?
}
