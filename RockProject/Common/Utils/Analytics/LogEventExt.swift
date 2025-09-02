import UIKit
import SwiftUI
import FirebaseAnalytics

extension UIViewController {
    
    public func logEvent(_ name: String, params: [String : Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
}

extension UIView {
    
    public func logEvent(_ name: String, params: [String : Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
}

extension View {
    
    public func logEvent(_ name: String, params: [String : Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
}
