
import Foundation
import SwiftUI

public class HostingViewWrapper<Content: View> {
    public var rootView: Content
    public let isNavigationBarHidden: Bool
    public let ignoresSafeArea: Bool
    public let ignoresKeyboard: Bool
    
    public init(rootView: Content,
                isNavigationBarHidden: Bool = true,
                ignoresSafeArea: Bool = true,
                ignoresKeyboard: Bool = true) {
        self.rootView = rootView
        self.isNavigationBarHidden = isNavigationBarHidden
        self.ignoresSafeArea = ignoresSafeArea
        self.ignoresKeyboard = ignoresKeyboard
    }

    public lazy var controller: AbsHostingController = {
        let controller = AbsHostingController(
            rootView: rootView,
            isNavigationBarHidden: isNavigationBarHidden,
            ignoresSafeArea: ignoresSafeArea,
            ignoresKeyboard: ignoresKeyboard
        )
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()

    public var view: UIView {
        controller.view
    }
}
