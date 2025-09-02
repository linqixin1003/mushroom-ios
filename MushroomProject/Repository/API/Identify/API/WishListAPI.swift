import Alamofire

// 获取心愿单列表
struct GetWishListRequest: RequestProtocol {
    let limit: Int
    let offset: Int
    let lang: String
    
    init(limit: Int = 20, offset: Int = 0, lang: String = "en") {
        self.limit = limit
        self.offset = offset
        self.lang = lang
    }
    
    var path: String {
        return "api/wishlist"
    }
    
    var needAuth: Bool {
        return true
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

struct GetWishListResponse: Codable {
    let total: Int
    let items: [WishListItem]
}

// 添加到心愿单
struct AddToWishListRequest: RequestProtocol {
    let mushroomId: String
    
    init(mushroomId: String) {
        self.mushroomId = mushroomId
    }
    
    var path: String {
        return "api/wishlist/add"
    }
    
    var needAuth: Bool {
        return true
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var parameters: [String : Any] {
        return [
            "mushroom_id": mushroomId
        ]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct AddToWishListResponse: Codable {
    let id: Int
}

// 从心愿单删除
struct RemoveFromWishListRequest: RequestProtocol {
    let itemId: String
    
    init(itemId: String) {
        self.itemId = itemId
    }
    
    var path: String {
        return "api/wishlist/remove?wish_id="+String(itemId)
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

struct RemoveFromWishListResponse: Codable {
    let success: Bool
    let message: String
}
