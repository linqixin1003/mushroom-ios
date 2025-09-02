
import Foundation
import SwiftUI

@available(iOS 13.0, *)
open class AbsHostingController<Content>: UIHostingController<Content> where Content : View {
    
    public init(rootView: Content,
                isNavigationBarHidden: Bool = true,
                ignoresSafeArea: Bool = true,
                ignoresKeyboard: Bool = true) {
        self.isNavigationBarHidden = isNavigationBarHidden
        super.init(rootView: rootView)
        
        if #available(iOS 16.0, *) {
            sizingOptions = [.intrinsicContentSize]
        }
        
        if ignoresSafeArea && IsIPhoneX {
            disableSafeArea()
        }
        
        if ignoresKeyboard {
            disableKeyboard()
        }
    }
    
    @MainActor required dynamic public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let isNavigationBarHidden: Bool
    
    // 在 NavigationController 中 使用 UIHostingController，在 iOS 15.x 的设备无法隐藏 navigationBar，解决方式如下：
    // 1. rootView 调用 .navigationBarHidden(true)
    // 2. 在 viewWillAppear(_ animated: Bool) 中 setNavigationBarHidden
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 16, *) {
        } else {
            self.navigationController?.setNavigationBarHidden(isNavigationBarHidden, animated: false)
            if isNavigationBarHidden {
                self.navigationController?.navigationBar.isTranslucent = false
                self.navigationController?.navigationBar.barTintColor = .clear
                self.navigationController?.navigationBar.backgroundColor = .clear
            }
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 16, *) {
        } else {
            self.navigationController?.setNavigationBarHidden(isNavigationBarHidden, animated: false)
            if isNavigationBarHidden {
                self.navigationController?.navigationBar.isTranslucent = false
                self.navigationController?.navigationBar.barTintColor = .clear
                self.navigationController?.navigationBar.backgroundColor = .clear
            }
        }
    }
}



@available(iOS 13.0, *)
extension UIHostingController {
    //https://stackoverflow.com/questions/70032739/why-does-swiftui-uihostingcontroller-have-extra-spacing/70339424#70339424
    
    convenience public init(rootView: Content, ignoresSafeArea: Bool = true, ignoresKeyboard: Bool = true) {
        self.init(rootView: rootView)
        
        if ignoresSafeArea && IsIPhoneX {
            disableSafeArea()
        }
        
        if ignoresKeyboard {
            disableKeyboard()
        }
    }
    
    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        } else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
            
            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                    return .zero
                }
                class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets),
                                imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
            }
            
            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
    
    //https://steipete.com/posts/disabling-keyboard-avoidance-in-swiftui-uihostingcontroller/
    func disableKeyboard() {
        guard let viewClass = object_getClass(view) else { return }
        
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoresKeyboard")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        }
        else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
            
            if let method = class_getInstanceMethod(viewClass, NSSelectorFromString("keyboardWillShowWithNotification:")) {
                let keyboardWillShow: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in }
                class_addMethod(viewSubclass, NSSelectorFromString("keyboardWillShowWithNotification:"),
                                imp_implementationWithBlock(keyboardWillShow), method_getTypeEncoding(method))
            }
            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}
