//
//  DeleteIdentificationRequest.swift
//  RockProject
//
//  Created by conalin on 2025/6/19.
//

import Alamofire

struct DeleteWishRequest: RequestProtocol {
    
    let stoneId: String
    
    init(stoneId: String) {
        self.stoneId = stoneId
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
        return ["stone_id": stoneId]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct DeleteWishResponse: Codable {
    let success: Bool
    let message: String
}



