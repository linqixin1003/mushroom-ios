import Foundation
import Security
import UIKit

class UDIDUtil {
    
    // MARK: - Constants
    
    private static var keychainUDIDItemIdentifier: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    private static var keyChainUDIDAccessGroup: String {
        let teamId = Config.teamId
        return "\(teamId).\(Bundle.main.bundleIdentifier ?? "")"
    }
    
    // MARK: - Public Methods
    
    static func getUDID() -> String? {
        var udid = getUDIDFromKeyChain()
        if udid.isEmpty {
            udid = _UDID_iOS7() ?? ""
            if udid.isEmpty {
                return nil
            }
            _ = settUDIDToKeyChain(udid)
        }
        return udid
    }
    
    static func resetUDID() {
        if let udid = _UDID_iOS7() {
            let randomSuffix = Int.random(in: 0...Int.max)
            let newUDID = "\(udid)-\(randomSuffix)"
            _ = settUDIDToKeyChain(newUDID)
        }
    }
    
    // MARK: - Private Methods
    
    private static func _UDID_iOS7() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    private static func getUDIDFromKeyChain(isVerifyNewUser: Bool = false) -> String {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrDescription as String: keychainUDIDItemIdentifier,
            kSecAttrGeneric as String: keychainUDIDItemIdentifier.data(using: .utf8) ?? Data(),
            kSecMatchCaseInsensitive as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        #if !targetEnvironment(simulator)
        query[kSecAttrAccessGroup as String] = keyChainUDIDAccessGroup
        #endif
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            print("KeyChain Item: \(keychainUDIDItemIdentifier) not found!!!")
            return ""
        } else if status != errSecSuccess {
            print("KeyChain Item query Error!!! Error code: \(status)")
            return ""
        }
        
        if let data = result as? Data,
           let udid = String(data: data, encoding: .utf8) {
            return udid
        }
        
        return ""
    }
    
    private static func settUDIDToKeyChain(_ udid: String) -> Bool {
        var dictForAdd: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrDescription as String: keychainUDIDItemIdentifier,
            kSecAttrGeneric as String: keychainUDIDItemIdentifier.data(using: .utf8) ?? Data(),
            kSecAttrAccount as String: keychainUDIDItemIdentifier,
            kSecAttrLabel as String: "",
            kSecValueData as String: udid.data(using: .utf8) ?? Data()
        ]
        
        #if !targetEnvironment(simulator)
        dictForAdd[kSecAttrAccessGroup as String] = keyChainUDIDAccessGroup
        #endif
        
        if getUDIDFromKeyChain().isEmpty {
            let status = SecItemAdd(dictForAdd as CFDictionary, nil)
            if status != errSecSuccess {
                print("Add KeyChain Item Error!!! Error Code: \(status)")
                return false
            }
            print("Add KeyChain Item Success!!!")
            return true
        } else {
            return updateUDIDInKeyChain(udid)
        }
    }
    
    private static func updateUDIDInKeyChain(_ newUDID: String) -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrGeneric as String: keychainUDIDItemIdentifier.data(using: .utf8) ?? Data(),
            kSecMatchCaseInsensitive as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true
        ]
        
        #if !targetEnvironment(simulator)
        query[kSecAttrAccessGroup as String] = keyChainUDIDAccessGroup
        #endif
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let queryResult = result as? [String: Any] else {
            return false
        }
        
        var updateDict: [String: Any] = [
            kSecAttrDescription as String: keychainUDIDItemIdentifier,
            kSecAttrGeneric as String: keychainUDIDItemIdentifier.data(using: .utf8) ?? Data(),
            kSecValueData as String: newUDID.data(using: .utf8) ?? Data()
        ]
        
        #if !targetEnvironment(simulator)
        updateDict[kSecAttrAccessGroup as String] = keyChainUDIDAccessGroup
        #endif
        
        var updateItem = queryResult
        updateItem[kSecClass as String] = kSecClassGenericPassword
        
        let updateStatus = SecItemUpdate(updateItem as CFDictionary, updateDict as CFDictionary)
        if updateStatus != errSecSuccess {
            print("Update KeyChain Item Error!!! Error Code: \(updateStatus)")
            return false
        }
        
        print("Update KeyChain Item Success!!!")
        return true
    }
}
