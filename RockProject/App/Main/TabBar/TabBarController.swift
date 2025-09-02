import UIKit

extension Notification.Name {
    static let TabbarReloadLanguage = Notification.Name(rawValue: "tabbarReloadLanguage")
}

@objc enum TabbarItemType: Int, CaseIterable {
    case home = 0
    case profile
    
    var barItemInfos: (normalIcon: String, selectIcon: String, title: String) {
        switch self {
        case .home:
            return (
                "icon_tabbar_home_normal",
                "icon_tabbar_home_selected",
                Language.tab_bar_home
            )
        case .profile:
            return (
                "icon_tabbar_me_normal",
                "icon_tabbar_me_selected",
                Language.tab_bar_profile
            )
        }
    }
    
    static var allTypes: [TabbarItemType] {
        Self.allCases
    }
    
    var controller: TabItemViewController {
        switch self {
        case .home:
            HomeViewController(type: self)
        case .profile:
            ProfileViewController(type: self)
        }
    }
    
    var event: String {
        switch self {
        case .home:
            return "home"
        case .profile:
            return "profile"
        }
    }
    
    var index: Int? {
        let index = Self.allTypes.firstIndex(of: self)
        return index
    }
    
    init?(index: Int) {
        let types = Self.allTypes
        
        if index < 0 || index >= types.count {
            return nil
        }
        
        self = types[index]
    }
    
    var isHome: Bool {
        return self == .home
    }
}

protocol TabbarProtocol {
    var currentSelectedIndex: Int {get set}
    var centerItemView: UIView {get}
    func updateBadge(at index: Int, count: Int)
    func itemView(at index: Int) -> UIView?
}

class TabBarController: UITabBarController {
    typealias Tabbar = UIView & TabbarProtocol
    private var myLocationManager = LocationManager()
    static var notificationNameTabbarItemClick: String {
        return "kNotificationNameTabBarItemClicked"
    }
    
    static var notificationTabbarItemClick: Notification.Name {
        return Notification.Name(rawValue: notificationNameTabbarItemClick)
    }
    
    override var selectedIndex: Int {
        didSet {
            self.privateMethods.change(preIndex: oldValue, to: selectedIndex)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 18, *), IsIPad {
            view.addSubview(self.tabbar)
//            self.mode = .tabSidebar
//            self.sidebar.isHidden = true
            self.traitOverrides.horizontalSizeClass = .compact
        }
        
        setupTabbar()
        setupControllers()
        self.selectedIndex = 0
        myLocationManager.locate()
        
        // 监听语言变化通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: LocalizationManager.languageChangedNotification,
            object: nil
        )
    }
    
    @objc private func languageChanged() {
        // 发送通知更新 TabBar 文本
        NotificationCenter.default.post(name: .TabbarReloadLanguage, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Public methods
    func itemView(type: TabbarItemType) -> UIView? {
        let index = Self.itemIndex(type: type)
        return self.tabbar.itemView(at: index)
    }
    
    func itemEvent(type: TabbarItemType) -> String {
        self.privateMethods.itemEvent(type: type)
    }
    
    var cameraItemView: UIView {
        return self.tabbar.centerItemView
    }
    
    func jumpToRoot(type: TabbarItemType) {
        guard let index = type.index else { return }
        self.privateMethods.popAndDismissToRoot()
        if selectedIndex != index {
            
        }
        if selectedIndex != index {
            self.selectedIndex = index
        }
    }
    
    func cameraAction() {
        FireBaseEvent.send(eventName: EventName.mainCameraClick)
        // self.privateMethods.cameraAction()
        let cameraVC = RecognizeViewController()
        self.present(cameraVC, animated: true, completion: nil)
    }
    
    func updateBadge(type: TabbarItemType, count: Int) {
        let index = Self.itemIndex(type: type)
        self.tabbar.updateBadge(at: index, count: count)
    }
    
    //MARK: - Private methods
    private func setupTabbar() {
        if #available(iOS 18, *), IsIPad {
            super.tabBar.alpha = 0.0
        }
        self.setValue(self.tabbar, forKey: "tabBar")
    }
    
    private func setupControllers() {
        self.tabControllers.forEach { vc in
            let navigationController = BaseNavigationViewController(rootViewController: vc)
            self.addChild(navigationController)
        }
    }
    
    //MARK: - Lazy load
    private lazy var tabItemTypes = TabbarItemType.allTypes
    
    lazy var tabEventNames: [String] = {
        tabItemTypes.map { $0.event }
    }()
    
    lazy var privateMethods: TabBarController.PrivateMethods = {
        TabBarController.PrivateMethods(delegate: self)
    }()
    
    private lazy var tabControllers: [TabItemViewController] = {
        tabItemTypes.map { $0.controller }
    }()
    
    lazy var tabbar: Tabbar = {
        let tabbar = TabBar(frame: .zero)
        tabbar.events = self.tabEventNames
        tabbar.centerItemHandler = { [weak self] in
            self?.cameraAction()
        }
        return tabbar
    }()
}

extension TabBarController {
    static var tabBarController: TabBarController? {
        return UIApplication.shared.delegate?.window??.rootViewController as? TabBarController
    }
    
    static var cameraIndex: Int {
        return -1
    }
    
    static func itemIndex(type: TabbarItemType) -> Int {
        return TabbarItemType.allTypes.firstIndex(of: type) ?? 0
    }
}

//MARK: - Autorotate
extension TabBarController {
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

extension TabBarController: TabBarControllerPrivateProtocol {}

extension UIViewController {
    func adaptPad18() {
        if #available(iOS 17.0, *), IsIPad {
            traitOverrides.horizontalSizeClass = .regular
        }
    }
}

extension UIViewController {
    static func swizzleViewWillLayoutSubviews() {
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, #selector(viewWillLayoutSubviews)) else { return }
        guard let swizzledMethod = class_getInstanceMethod(UIViewController.self, #selector(swizzled_layoutSubviews)) else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc func swizzled_layoutSubviews() {
        swizzled_layoutSubviews()
        adjustSizeClass()
    }
    
    var windowSizeClass: UIUserInterfaceSizeClass? {
        guard let windowSizeClass = KeyWindow()
        else { return nil }
        return windowSizeClass.traitCollection.horizontalSizeClass
    }
    
    func adjustSizeClass() {
        guard #available(iOS 18, *), IsIPad else {
            return
        }
        
        if self is UITabBarController {
            traitOverrides.horizontalSizeClass = .compact
            return
        }
        
        if let windowSizeClass {
            traitOverrides.horizontalSizeClass = windowSizeClass
        }
    }
}
