import Alamofire

// 获取收藏列表 - 对齐Android的ListCollectionRequest
struct ListCollectionRequest: RequestProtocol {
    let limit: Int
    let offset: Int
    let lang: String
    
    init(limit: Int = 20, offset: Int = 0, lang: String = "en") {
        self.limit = limit
        self.offset = offset
        self.lang = lang
    }
    
    var path: String {
        return "api/collection"
    }
    
    var needAuth: Bool {
        return false
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String : Any] {
        return [
            "limit": limit,
            "offset": offset,
            "lang": lang
        ]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct ListCollectionResponse: Codable {
    let total: Int
    let items: [CollectionRecord]
}

// 添加到收藏 - 对齐Android的CollectionAddRequest
struct CollectionAddRequest: RequestProtocol {
    let identificationId: Int
    
    init(identificationId: Int) {
        self.identificationId = identificationId
    }
    
    var path: String {
        return "api/collection/add"
    }
    
    var needAuth: Bool {
        return true
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var parameters: [String : Any] {
        return [
            "identification_id": identificationId
        ]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct CollectionAddResponse: Codable {
    let success: Bool
    let message: String
}

// 从收藏删除 - 对齐Android的DeleteCollectionRequest
struct DeleteCollectionRequest: RequestProtocol {
    let collectionId: Int
    
    init(collectionId: Int) {
        self.collectionId = collectionId
    }
    
    var path: String {
        return "api/collection/remove?collection_id=" + String(collectionId)
    }
    
    var needAuth: Bool {
        return true
    }
    
    var method: HTTPMethod {
        return .delete
    }
    
    var parameters: [String : Any] {
        return [:]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct DeleteCollectionResponse: Codable {
    let success: Bool
    let message: String
}
