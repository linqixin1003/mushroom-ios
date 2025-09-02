//
//  DeleteIdentificationRequest.swift
//  RockProject
//
//  Created by conalin on 2025/6/19.
//

import Alamofire

struct DeleteWishRequest: RequestProtocol {
    
    let mushroomId: String
    
    init(mushroomId: String) {
        self.mushroomId = mushroomId
    }
    
    var path: String {
        return "api/wishlist/remove"
    }
    
    var needAuth: Bool {
        return false
    }
    
    var method: HTTPMethod {
        return .delete
    }
    
    var parameters: [String: Any] {
        return ["mushroom_id": mushroomId]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct DeleteWishResponse: Codable {
    let success: Bool
    let message: String
}



