import SwiftUI
import Lightbox
import UIKit

class ViewImageUtil{
    static func show(parent:UIViewController, position:Int, imageUrls:[String]){
        let images = imageUrls.map { url in
            LightboxImage(imageURL: URL(string: url)!)
        }
        let controller = LightboxController(images: images, startIndex: position)
        controller.dynamicBackground = true
        
        // 自定义关闭按钮
        controller.headerView.closeButton.setImage(UIImage(named: "icon_close2"), for: .normal)
        // 移除背景色和边框
        controller.headerView.closeButton.backgroundColor = .clear
        controller.headerView.closeButton.layer.cornerRadius = 14 // 设置圆角为宽度的一半
        
        if parent.presentedViewController == nil {
            parent.present(controller, animated: true)
        } else {
            if let topVC = topViewController(), topVC.presentedViewController == nil {
                topVC.present(controller, animated: true)
            }
        }
    }
    
    static func show(parent:UIViewController, position:Int, imageUrls:[UIImage]){
        let images = imageUrls.map { url in
            LightboxImage(image: url)
        }
        let controller = LightboxController(images: images, startIndex: position)
        controller.dynamicBackground = true
        
        // 自定义关闭按钮
        controller.headerView.closeButton.setImage(UIImage(named: "icon_close2"), for: .normal)
        // 移除背景色和边框
        controller.headerView.closeButton.backgroundColor = .clear
        controller.headerView.closeButton.layer.cornerRadius = 14 // 设置圆角为宽度的一半
        
        if parent.presentedViewController == nil {
            parent.present(controller, animated: true)
        } else {
            if let topVC = topViewController(), topVC.presentedViewController == nil {
                topVC.present(controller, animated: true)
            }
        }
    }
    
    static func initNetWork(){
        // 配置图片加载器
        LightboxConfig.loadImage = { imageView, url, completion in
            Task{ @MainActor in
                imageView.kf.setImage(with: url) { result in
                    switch result {
                    case .success(let value):
                        completion?(value.image)
                    case .failure(_):
                        completion?(nil)
                    }
                }
            }
        }
        
        // 配置关闭按钮样式
        LightboxConfig.CloseButton.image = UIImage(named: "convertpage_close")
        LightboxConfig.CloseButton.text = ""  // 移除文字
        LightboxConfig.CloseButton.size = CGSize(width: 28, height: 28)  // 设置按钮大小
        LightboxConfig.CloseButton.textAttributes = [
            .font: UIFont.systemFont(ofSize: 0),
            .foregroundColor: UIColor.clear
        ]
    }
    
    static func topViewController(_ rootViewController: UIViewController? = nil) -> UIViewController? {
        let root = rootViewController ?? UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: { $0.isKeyWindow })?.rootViewController
        
        if let navigationController = root as? UINavigationController {
            return topViewController(navigationController.visibleViewController)
        }
        if let tabBarController = root as? UITabBarController {
            return topViewController(tabBarController.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return topViewController(presented)
        }
        return root
    }
}

