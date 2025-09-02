

import UIKit

class ToastUtil {
    
    static func showToast(_ message : String) {
        guard let window = UIApplication.shared.delegate?.window else {
            return
        }
        let toastLabel = UILabel(frame: CGRect(x: window!.frame.size.width/2 - 85, y: window!.frame.size.height-200, width: 180, height: 55))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.numberOfLines = 2
        toastLabel.textColor = UIColor.white
        toastLabel.font = .regularKanit(16)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        window!.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveLinear, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    /// Show network timeout error message centered on screen for 3 seconds
    static func showNetworkTimeoutError() {
        showCenteredToast("Network timeout, please try again!", duration: 3.0)
    }
    
    /// Show a centered toast message with custom duration
    static func showCenteredToast(_ message: String, duration: TimeInterval = 3.0) {
        guard let window = UIApplication.shared.delegate?.window else {
            return
        }
        
        // Remove any existing toast first
        window?.subviews.forEach { view in
            if view.tag == 999888 { // Use a unique tag to identify our toast
                view.removeFromSuperview()
            }
        }
        
        // Create container view for better layout control
        let containerView = UIView()
        containerView.tag = 999888
        containerView.backgroundColor = UIColor.clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create toast label
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        toastLabel.text = message
        toastLabel.layer.cornerRadius = 12
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add padding to the label
        let padding: CGFloat = 20
        
        window!.addSubview(containerView)
        
        // Setup constraints for container (full screen)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: window!.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: window!.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: window!.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: window!.bottomAnchor)
        ])
        
        // Create a padding view to contain the label
        let paddingView = UIView()
        paddingView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        paddingView.layer.cornerRadius = 12
        paddingView.clipsToBounds = true
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        
        // Reset label background since padding view handles it now
        toastLabel.backgroundColor = UIColor.clear
        
        paddingView.addSubview(toastLabel)
        containerView.addSubview(paddingView)
        
        // Setup constraints for padding view (centered)
        NSLayoutConstraint.activate([
            paddingView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            paddingView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            paddingView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 40),
            paddingView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -40)
        ])
        
        // Setup constraints for label inside padding view
        NSLayoutConstraint.activate([
            toastLabel.topAnchor.constraint(equalTo: paddingView.topAnchor, constant: padding/2),
            toastLabel.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor, constant: padding),
            toastLabel.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor, constant: -padding),
            toastLabel.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor, constant: -padding/2)
        ])
        
        // Set initial alpha and animate
        containerView.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            containerView.alpha = 1.0
        }) { _ in
            // After showing, wait for duration then fade out
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseInOut, animations: {
                containerView.alpha = 0.0
            }) { _ in
                containerView.removeFromSuperview()
            }
        }
    }
}
