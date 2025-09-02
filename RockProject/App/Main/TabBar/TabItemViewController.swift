
import UIKit

class TabItemViewController: UIViewController {
    let type: TabbarItemType
    private(set) var uiHasLoaded: Bool = false // UI是否加载成功过
    private(set) var hasEntered: Bool = false // 是否进入到这个tab, 在转化页显示完之前不算
    private(set) var isInThisTab: Bool = false
    var selected: Bool = false {
        didSet {
            if selected != oldValue {
                if selected {
                    self.enter()
                } else {
                    self.leave()
                }
            }
        }
    }
    
    init(type: TabbarItemType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.basicUI()
        
        if self.type.isHome {
            self.hasEntered = true
            self.isInThisTab = true
            self.realDidLoad()
        } else {
            self.hasEntered = true
            self.realDidLoad()
        }
    }
    
    func realDidLoad() {
        self._loadUI()
    }
    
    private func basicUI() {
        self.view.backgroundColor = .pageBG
        view.addSubviews([self.tabItemContentView])
        
        self.tabItemContentView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(TabBarHeight)
        }
    }
    
    // overrode this methods to loadUI
    func loadUI(completion: @escaping (_ succeed: Bool)->()) {}
    
    func retryRequest() {
        // TODO: tracking
        self._loadUI()
    }
    
    private func _loadUI() {
        self.loadUI {[weak self] succeed in
            guard let self = self else { return }
            if succeed {
                self.uiHasLoaded = true
            } else {
                self.showRequestFailed()
            }
        }
    }
    
    func showRequestFailed() {
        // TODO: tracking
        self.tabItemContentView.addSubview(self.errorView)
        self.errorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            if IsIPad {
                make.width.equalTo(400.0)
            } else {
                make.leading.equalTo(40.0)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // Sub class can override these classes
    @objc open func enter() {
        if !self.hasEntered { return }
        self.isInThisTab = true
    }
    
    @objc open func leave() {
        if !self.hasEntered { return }
        self.isInThisTab = false
    }
    
    //MARK: - Method
    func overrideTabbarCameraAction() -> Bool {
        return false
    }
    
    private(set) lazy var tabItemContentView = UIView()
    
    private lazy var errorView: NetworkRequestErrorView = {
        let errorView = NetworkRequestErrorView()
        errorView.handler = {[weak self] in
            self?.errorView.removeFromSuperview()
            self?.retryRequest()
        }
        return errorView
    }()
}
