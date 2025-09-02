import Foundation

struct Mushroom: Codable {
    let id: String
    let scientificName: String?
    let commonName: String?
    let organismType: String?
    let primaryRef: String?
    let secondaryRef: String?
    let primaryImage: String?
    let commonNames: [String]?
    let tags: [MushroomTag]?
    let languages: [String]?
    let synonyms: [String]?
    let name: String
    let description: String?
    let summary: String?
    let taxonomy: String?
    let edibility: String?
    let toxicity: String?
    let habitatAndDistribution: String?
    let ecology: String?
    let morphology: String?
    let similarSpecies: String?
    let identification: String?
    let fullTextContent: String?
    let imageUrl: String?
    let confidence: Double?

    init(
        id: String,
        scientificName: String? = nil,
        commonName: String? = nil,
        organismType: String? = nil,
        primaryRef: String? = nil,
        secondaryRef: String? = nil,
        primaryImage: String? = nil,
        commonNames: [String]? = nil,
        tags: [MushroomTag]? = nil,
        languages: [String]? = nil,
        synonyms: [String]? = nil,
        name: String,
        description: String? = nil,
        summary: String? = nil,
        taxonomy: String? = nil,
        edibility: String? = nil,
        toxicity: String? = nil,
        habitatAndDistribution: String? = nil,
        ecology: String? = nil,
        morphology: String? = nil,
        similarSpecies: String? = nil,
        identification: String? = nil,
        fullTextContent: String? = nil,
        imageUrl: String? = nil,
        confidence: Double? = nil) {
        self.id = id
        self.scientificName = scientificName
        self.commonName = commonName
        self.organismType = organismType
        self.primaryRef = primaryRef
        self.secondaryRef = secondaryRef
        self.primaryImage = primaryImage
        self.commonNames = commonNames
        self.tags = tags
        self.languages = languages
        self.synonyms = synonyms
        self.name = name
        self.description = description
        self.summary = summary
        self.taxonomy = taxonomy
        self.edibility = edibility
        self.toxicity = toxicity
        self.habitatAndDistribution = habitatAndDistribution
        self.ecology = ecology
        self.morphology = morphology
        self.similarSpecies = similarSpecies
        self.identification = identification
        self.fullTextContent = fullTextContent
        self.imageUrl = imageUrl
        self.confidence = confidence
    }

    enum CodingKeys: String, CodingKey {
        case id
        case scientificName = "scientific_name"
        case commonName = "common_name"
        case organismType = "organism_type"
        case primaryRef = "primary_ref"
        case secondaryRef = "secondary_ref"
        case primaryImage = "primary_image"
        case commonNames = "common_names"
        case tags
        case languages
        case synonyms
        case name
        case description
        case summary
        case taxonomy
        case edibility
        case toxicity
        case habitatAndDistribution = "habitat_and_distribution"
        case ecology
        case morphology
        case similarSpecies = "similar_species"
        case identification
        case fullTextContent = "full_text_content"
        case imageUrl = "image_url"
        case confidence
    }
}
