

import Foundation

class Config {
    
    static let HOST = "https://mushroom.birdid.net"
    
    static let URL_TERMS_OF_USE = "https://lingjuetech.github.io/document-privacy-policy/TermsOfUse.html"
    static let URL_PRIVACY_POLICY = "https://lingjuetech.github.io/document-privacy-policy/privacy-policy.html"
    
    static let EMAIL_CONTACT_US = "lingjuetech@gmail.com"
    
    static let appId: String = "6747975116" // TODO: appId
    static let teamId: String  = "" // TODO: teamId
    
    static let EMAIL:String = "lingjuetech@gmail.com"
    
    static let shareAppUrl = URL(string: "itms-apps://itunes.apple.com/app/\(appId)?action=write-review")
    
    // MARK: - Network Configuration
    
    /// Network request timeout interval in seconds
    static let NETWORK_TIMEOUT_INTERVAL: TimeInterval = 60.0
    
}
