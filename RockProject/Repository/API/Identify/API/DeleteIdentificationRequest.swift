//
//  DeleteIdentificationRequest.swift
//  RockProject
//
//  Created by conalin on 2025/6/19.
//

import Alamofire

struct DeleteIdentificationRequest: RequestProtocol {
    
    let identifyId: String
    
    init(identifyId: String) {
        self.identifyId = identifyId
    }
    
    var path: String {
        return "api/stones/identifications?identification_id="+identifyId
    }
    
    var needAuth: Bool {
        return false
    }
    
    var method: HTTPMethod {
        return .delete
    }
    
    var parameters: [String: Any] {
        return [:]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}

struct DeleteIdentificationResponse: Codable {
    let message: String
}



