
import UIKit

protocol TabBarControllerPrivateProtocol: NSObjectProtocol {
    var tabbar: TabBarController.Tabbar {get}
    var tabEventNames: [String] {get}
}

extension TabBarController {
    class PrivateMethods {
        private unowned var delegate: (UITabBarController & TabBarControllerPrivateProtocol)
        
        init(delegate: TabBarController & TabBarControllerPrivateProtocol) {
            self.delegate = delegate
        }
        
        var currentTabEventName: String {
            return tabEventNameAt(self.delegate.selectedIndex)
        }
        
        func itemEvent(type: TabbarItemType) -> String {
            let index = TabBarController.itemIndex(type: type)
            let count = self.delegate.tabEventNames.count;
            if index >= 0 && index < count {
                return self.delegate.tabEventNames[index]
            }
            return ""
        }
        
        func tabEventNameAt(_ index: Int) -> String {
            let count = self.delegate.tabEventNames.count;
            if index >= 0 && index < count {
                return self.delegate.tabEventNames[index]
            }
            return ""
        }
        
        func popAndDismissToRoot() {
            guard let navigationController = self.delegate.selectedViewController as? UINavigationController else {
                return
            }
            navigationController.popToRootViewController(animated: false)
            if delegate.presentedViewController != nil {
                delegate.dismiss(animated: false, completion: nil)
            }
        }
        
        func change(preIndex: Int, to currentIndex: Int) {
            self.tabItemViewControllerAtIndex(preIndex)?.selected = false
            self.tabItemViewControllerAtIndex(currentIndex)?.selected = true
            postTabbarItemClicked(currentIndex)
            // TODO: 111 track event
        }
        
        func cameraAction() {
            if let currentTabController = currentTabController, currentTabController.overrideTabbarCameraAction() {
                return
            }
            postTabbarItemClicked(TabBarController.cameraIndex)
        }
        
        func tabViewControllerOfType(_ type: TabbarItemType) -> UIViewController? {
            guard let index = type.index else { return nil }
            guard let list = self.delegate.viewControllers, index >= 0, index < list.count else {
                return nil
            }
            let vc = list[index];
            if let nav = vc as? UINavigationController {
                return nav.viewControllers.first
            }
            return vc
        }
        
        //MARK: - Private methods
        private func tabItemViewControllerAtIndex(_ index: Int) -> TabItemViewController? {
            guard let list = self.delegate.viewControllers, index >= 0, index < list.count else { return nil }
            return list[index].tabItemViewController
        }
        
        private var currentTabController: TabItemViewController? {
            return self.delegate.selectedViewController?.tabItemViewController
        }
        
        private func postTabbarItemClicked(_ index: Int) {
            NotificationCenter.default.post(name: TabBarController.notificationTabbarItemClick, object: ["tabBarItemIndex": index])
        }
    }
}

fileprivate extension UIViewController {
    var tabItemViewController: TabItemViewController? {
        if let vc = self as? TabItemViewController {
            return vc
        }
        if let nav = self as? UINavigationController, let tabVc = nav.viewControllers.first as? TabItemViewController {
            return tabVc
        }
        return nil
    }
}

