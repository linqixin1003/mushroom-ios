

import Foundation
import UIKit

class LoadingUtil {
    
    private static let shared = LoadingUtil()
    
    private var alert: UIAlertController? = nil
    
    private func showLoadingAlert(message: String = Language.text_loading) {
        if let alert = self.alert {
            alert.dismiss(animated: false)
            self.alert = nil
        }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        alert.view.heightAnchor.constraint(equalToConstant: 95).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor).isActive = true
        loadingIndicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20).isActive = true
        self.alert = alert
        if let topVC = UIViewController.topViewController() {
            topVC.present(alert, animated: true)
        }
    }
    
    static func showLoading(message: String = Language.text_loading) {
        Self.shared.showLoadingAlert(message: message)
    }
    
    static func dismiss(animated: Bool = true) {
        if let currentAlert = Self.shared.alert {
            currentAlert.dismiss(animated: false)
            Self.shared.alert = nil
        }
    }
}
