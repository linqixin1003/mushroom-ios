
import UIKit
import SnapKit

@objc
class TabBar: UITabBar {
    @objc var centerItemHandler: (()->())?
    @objc var events: [String]?
    
    private let enableCenterItem: Bool = true
    
    @objc
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configUI()
        configTabbarItems()
        
        NotificationCenter.default.addObserver(forName: .TabbarReloadLanguage, object: nil, queue: .main) {[weak self] _ in
            self?.reloadLanguage()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        if self.enableCenterItem {
            addSubview(self.shaderView)
            shaderView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.snp.top)
                make.height.equalTo(shaderView.gHeight)
            }
        } else {
            self.shell.addSubview(self.line)
            self.line.snp.makeConstraints { make in
                make.leading.trailing.top.equalToSuperview()
                make.height.equalTo(1)
            }
        }
        
        addSubview(self.shell)
        shell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.shell.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(SafeBottom)
        }
        
        if !self.enableCenterItem {
            self.shell.bringSubviewToFront(self.line)
        }
    }
    
    private func configTabbarItems() {
        var itemViews: [UIView] = self.tabBarItems
        if self.enableCenterItem {
            itemViews.insert(centerItem, at: self.tabBarItems.count/2)
        }
        self.contentView.addSubviews(itemViews)
        
        var lastView: UIView? = nil
        itemViews.forEach { itemView in
            itemView.snp.makeConstraints { make in
                if let lastView = lastView {
                    make.leading.equalTo(lastView.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
                
                if itemView == self.centerItem {
                    make.size.equalTo(self.centerItem.size)
                    make.bottom.equalToSuperview().inset(self.centerItem.bottomEdge)
                    make.centerX.equalToSuperview()
                } else {
                    make.top.bottom.equalToSuperview()
                }
            }
            lastView = itemView
        }
        lastView?.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
        }
        Self.unionTabbarItmes(self.tabBarItems)
    }
    
    private func showIndex(_ index: Int) {
        tabBarItems.enumerated().forEach { (aindex, item) in
            let selected = (aindex == index)
            if item.selected != selected {
                item.selected = selected
            }
        }
    }
    
    private func reloadLanguage() {
        let texts: [String] = self.getCurrentBarItemInfos().map {$0.title}
        
        texts.enumerated().forEach { element in
            let item = self.tabBarItems[element.offset]
            item.title = element.element
        }
    }
    
    //MARK: - Private actions
    @objc
    private func centerButtonClickAction() {
        centerItemHandler?()
    }
    
    //MARK: - Overrid
    override func layoutSubviews() {
        super.layoutSubviews()
        self.subviews.forEach { subView in
            if subView !== self.shell && subView !== self.shaderView {
                subView.isHidden = true
            }
        }
        self.bringSubviewToFront(self.shell)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden {
            return super.hitTest(point, with: event)
        }
        
        let tempPoint = self.centerItem.convert(point, from: self)
        if self.centerItem.bounds.contains(tempPoint) {
            return self.centerItem.button
        } else {
            var tempPoint = self.contentView.convert(point, from: self)
            if self.contentView.bounds.contains(tempPoint) && point.y < 0 {
                tempPoint.y = 2.0
                return super.hitTest(tempPoint, with: event)
            }
            return super.hitTest(point, with: event)
        }
    }
    
    override var selectedItem: UITabBarItem? {
        didSet {
            guard let selectedItem = selectedItem, let index = self.items?.firstIndex(of: selectedItem) else {
                return
            }
            currentSelectedIndex = index
        }
    }
    
    private func getCurrentBarItemInfos() -> [(normalIcon: String, selectIcon: String, title: String)] {
        let barItemInfos: [(normalIcon: String, selectIcon: String, title: String)] = TabbarItemType.allTypes.map {$0.barItemInfos}
        return barItemInfos
    }
    
    //MARK: - Lazy load
    private lazy var barItemInfos: [(normalIcon: String, selectIcon: String, title: String)] = {
        getCurrentBarItemInfos()
    }()
    
    private(set) lazy var tabBarItems: [TabBarItem] = {
        let tabBarItems:[TabBarItem] = barItemInfos.map { info in
            let item = TabBarItem(normalIcon: info.normalIcon,
                                  selectedIcon: info.selectIcon,
                                  title: info.title,
                                  font: UIFont.mediumKanit(12),
                                  selectedFont: UIFont.mediumKanit(12),
                                  normalColor: .fromHex(0x868686),
                                  selectedColor: .primary)
            item.badgeHidden = true
            item.delegate = self
            return item
        }
        return tabBarItems
    }()
    
    private(set) lazy var centerItem: TabBarCenterBaseItem = {
        let centerItem = TabBarCenterItem()
        centerItem.button.addTarget(self, action: #selector(centerButtonClickAction), for: .touchUpInside)
        return centerItem
    }()
    
    private lazy var shaderView: TabbarShaderView = {
        TabbarShaderView()
    }()
    
    private lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = .fromHex(0xF5F5F5)
        return view
    }()
    
    private lazy var shell: UIView = {
        let shell = UIView()
        shell.backgroundColor = .clear
        return shell
    }()
    private lazy var contentView: UIView = UIView()
}

extension TabBar: TripleButtonDelegage {
    func tripleButton(_ sender: AnyObject, event: TripleButtonEvent) {
        guard let item = sender as? TabBarItem,
              let index = self.tabBarItems.firstIndex(of: item),
              let tabbarController = self.delegate as? UITabBarController else {
                  return
              }
        tabbarController.selectedIndex = index
        if index == 0 {
            FireBaseEvent.send(eventName: EventName.mainHomeClick)
        } else if index == 1 {
            FireBaseEvent.send(eventName: EventName.mainMineClick)
        }
        if event == .select {
            self.trackItemClick(index)
        }
    }
}

extension TabBar: TabbarProtocol {
    var currentSelectedIndex: Int {
        get {
            guard let selectedItem = selectedItem, let index = self.items?.firstIndex(of: selectedItem) else {
                return 0
            }
            return index
        }
        set {
            showIndex(newValue)
        }
    }
    
    var centerItemView: UIView {
        return self.centerItem
    }
    
    func updateBadge(at index: Int, count: Int) {
    }
    
    func itemView(at index: Int) -> UIView? {
        tabbarItemAtIndex(index)
    }
    
    private func tabbarItemAtIndex(_ index: Int) -> UIView? {
        if index < 0 || index >= self.tabBarItems.count {
            return nil
        }
        
        return self.tabBarItems[index]
    }
}

extension TabBar {
    static func unionTabbarItmes(_ items: [TabBarItem]) {
        var lastView: UIView? = nil
        items.forEach { item in
            if let lastView = lastView {
                item.snp.makeConstraints { make in
                    make.width.equalTo(lastView.snp.width)
                }
            }
            lastView = item
        }
    }
}

// MARK: Tracking
extension TabBar {
    
    func trackItemClick(_ index: Int) {
        guard let type = TabbarItemType(index: index) else { return }
        let event = type.event
        // TODO: 111 tracking
    }
}
