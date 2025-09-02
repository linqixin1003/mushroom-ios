
import UIKit
import SwiftUI

open class BaseHostingViewController<Content: View>: BaseViewController {
    public var rootView: Content
    public var navigationTitle: String?
    
    public init(rootView: Content, title: String? = nil, from: String = "") {
        self.rootView = rootView
        self.navigationTitle = title
        super.init(from: from)
        self.modalPresentationStyle = .fullScreen
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setNavigationView() {
        super.setNavigationView()
        
        self.navigationView.title = self.navigationTitle
    }
    
    open override func setupSwiftUIView() {
        super.setupSwiftUIView()
        
        addSwiftUI(viewController: hostingController) { make in
            make.edges.equalToSuperview()
        }
    }
    
    public lazy var hostingController: AbsHostingController = {
        let controller = AbsHostingController(rootView: rootView)
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    
    public var hostingView: UIView {
        hostingController.view
    }
}
