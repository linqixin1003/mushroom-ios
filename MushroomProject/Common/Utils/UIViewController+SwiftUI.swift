
import Foundation
import SnapKit
import SwiftUI

extension UIViewController {
    public func addSwiftUI<T: View>(
        viewController: UIHostingController<T>,
        parentView: UIView? = nil,
        _ closure: (_ make: ConstraintMaker) -> Void
    ) {
        let view = parentView ?? self.view!
        let swiftuiView = viewController.view!
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(viewController)
        view.addSubview(swiftuiView)
        viewController.view.snp.makeConstraints(closure)
        viewController.didMove(toParent: self)
    }
    
    public func addSwiftUI<T: View>(
        _ wrapper: HostingViewWrapper<T>,
        parentView: UIView? = nil,
        _ closure: (_ make: ConstraintMaker) -> Void
    ) {
        guard let view = parentView ?? self.view else { return }
        self.addChild(wrapper.controller)
        view.addSubview(wrapper.view)
        wrapper.view.snp.makeConstraints(closure)
        wrapper.controller.didMove(toParent: self)
    }
}

extension UIView {
    public func addSwiftUI<T: View>(
        viewController: UIHostingController<T>,
        _ closure: (_ make: ConstraintMaker) -> Void
    ) {
        let swiftuiView = viewController.view!
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(swiftuiView)
        viewController.view.snp.makeConstraints(closure)
    }
    
    public func addSwiftUI<T: View>(
        _ wrapper: HostingViewWrapper<T>,
        _ closure: (_ make: ConstraintMaker) -> Void
    ) {
        let swiftuiView = wrapper.view
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(swiftuiView)
        wrapper.view.snp.makeConstraints(closure)
    }
}
