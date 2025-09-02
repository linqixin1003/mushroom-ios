

import UIKit

@objc(BaseNavigationViewController)
class BaseNavigationViewController: UINavigationController {
    
    /// true: 表示下一次present modal style 不会默认置为fullScreen
    @objc public var customNextModalStyle = false
    
    // MARK: Override
    override var shouldAutorotate: Bool {
        get {
            return true
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    // MARK: - Life Circel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isTranslucent = false
        self.navigationBar.backgroundColor = .white
        self.delegate = self
        
        //右滑返回手势的代理
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    // MARK: - Override
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //在push的过程中禁止右滑
        self.interactivePopGestureRecognizer?.isEnabled = false
        
        if self.viewControllers.count >= 1 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if !self.customNextModalStyle {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        }
        self.customNextModalStyle = false
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if self.viewControllers.count > 1 {
            viewControllers.last?.hidesBottomBarWhenPushed = true
        }
        
        super.setViewControllers(viewControllers, animated: animated)
    }
}

// MARK: - UINavigationControllerDelegate

extension BaseNavigationViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // 恢复右滑功能
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        
        if navigationController.viewControllers.count == 1 {
            viewController.hidesBottomBarWhenPushed = false
        }
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension BaseNavigationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count == 1 {
            return false
        }
        return true
    }
}
