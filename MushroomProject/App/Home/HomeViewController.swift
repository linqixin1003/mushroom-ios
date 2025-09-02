import UIKit
import SnapKit
import Combine

class HomeViewController: TabItemViewController {
    let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.homeOpen, closeEventName: EventName.homeClose)
    private let viewModel = HomeViewModel()
    private let actionModel = HomeActionModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func realDidLoad() {
        super.realDidLoad()
        self.setActions()
        self.observeNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 每次页面即将显示时刷新收藏状态，确保数据是最新的
        self.viewModel.refreshCollectionStates()
    }
    
    override func loadUI(completion: @escaping (Bool) -> ()) {
        self.setupUI()
        self.loadData(completion: completion)
    }
    
    private func setupUI() {
        // 清理旧的UI
        self.children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        self.tabItemContentView.subviews.forEach {
            $0.removeFromSuperview()
        }

        let hostingView = AbsHostingController(rootView: self.contentView)
        hostingView.view.backgroundColor = .clear
        
        self.addChild(hostingView)
        self.tabItemContentView.addSwiftUI(viewController: hostingView) { make in
            make.edges.equalToSuperview()
        }
        hostingView.didMove(toParent: self)
    }
    
    private func setActions() {
        self.actionModel.onSearchClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.homeSearchClick)
            guard let self else { return }
            let vc = SearchViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }.store(in: &cancellables)
        
        self.actionModel.onVipBannerClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.homeVipClick)
            guard let _ = self else { return }
            ConvertViewController.present()
        }.store(in: &cancellables)
        
        self.actionModel.onIdentifyClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.homeIdentifyClick)
            guard let self else { return }
            if let tabbarController = TabBarController.tabBarController {
                let vc = RecognizeViewController()
                tabbarController.present(vc, animated: true)
            }
        }.store(in: &cancellables)

        self.actionModel.onValuationClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.homeValuationClick)
            guard let self else { return }
            if let tabbarController = TabBarController.tabBarController {
                let vc = ValuationViewController()
                tabbarController.present(vc, animated: true)
            }
        }.store(in: &cancellables)
        
        self.actionModel.onRecordClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.homeRecordClick)
            guard let self else { return }
            if let tabbarController = TabBarController.tabBarController {
                let vc = RecognizeViewController()
                tabbarController.present(vc, animated: true)
            }
        }.store(in: &cancellables)
        
        self.actionModel.onDetectorClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.homeDetectorClick)
            guard let self else { return }
            // 启动寻宝活动 - 金属探测器功能
            let vc = FindTreasureViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }.store(in: &cancellables)
        
        self.actionModel.onDailyMushroomClick.sink { [weak self] id in
            FireBaseEvent.send(eventName: EventName.homeDailyMushroomItemClick, params: [EventParam.uid: id])
            guard let self else { return }
            let vc = DetailViewController(id: id)
            self.navigationController?.pushViewController(vc, animated: true)
        }.store(in: &cancellables)
        
        self.actionModel.onDailyMushroomCollectClick.sink { [weak self] id in
            FireBaseEvent.send(eventName: EventName.homeDailyMushroomFavoriteClick, params: [EventParam.uid: id])
            guard let self else { return }
            self.viewModel.toggleCollectionState(id: id) { success in
                if success {
//                    let isNowCollected = self.viewModel.isCollected(id: id)
//                    let message = isNowCollected ? "Added to collection" : "Removed from collection"
//                    ToastUtil.showToast(message)
                } else {
//                    ToastUtil.showToast("Operation failed, please try again")
                }
            }
        }.store(in: &cancellables)
        
        self.actionModel.onNearbyMushroomItemClick.sink { [weak self] id in
            FireBaseEvent.send(eventName: EventName.homeNearbyMushroomItemClick, params: [EventParam.uid: id])
            guard let self else { return }
            let vc = DetailViewController(id: id)
            self.navigationController?.pushViewController(vc, animated: true)
        }.store(in: &cancellables)
        
        self.actionModel.onNearbyMushroomViewAllClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.homeNearbyMushroomMoreClick)
            guard let self else { return }
            ToastUtil.showToast("Feature coming soon!")
        }.store(in: &cancellables)
        
        // 处理分享事件
        self.actionModel.onShareClick.sink { [weak self] shareData in
            guard let self else { return }
            self.handleShare(shareData: shareData)
        }.store(in: &cancellables)
        
        // 处理每日石头分享事件
        self.actionModel.onDailyMushroomShareClick.sink { [weak self] id in
            FireBaseEvent.send(eventName: EventName.homeDailyMushroomShareClick, params: [EventParam.uid: id])
            guard let self else { return }
            self.handleDailyMushroomShare(id: id)
        }.store(in: &cancellables)
    }
    
    private func observeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .VipInfoChanged, object: nil)
        // 监听收藏状态变更通知，及时刷新首页的收藏状态
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCollectionStates), name: .ReloadHistoryList, object: nil)
        // 监听语言变化通知
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: LocalizationManager.languageChangedNotification, object: nil)
    }
    
    @objc
    private func languageChanged() {
        // 强制刷新SwiftUI视图
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 重新创建contentView以应用新的语言
            self.setupUI()
        }
    }
    
    @objc
    private func refreshCollectionStates() {
        self.viewModel.refreshCollectionStates()
    }
    
    @objc
    private func reloadData() {
        self.loadData { [weak self] success in
            guard self != nil else { return }
            debugPrint("[HomeViewController] loadData - success: \(success)")
        }
    }
    
    private func loadData(completion: @escaping (Bool) -> ()) {
        self.viewModel.loadData { [weak self] success in
            guard self != nil else { return }
            completion(success)
        }
    }
    
    private lazy var contentView: HomePage = {
        let view = HomePage(viewModel: self.viewModel, actionModel: self.actionModel)
        return view
    }()
    
    // MARK: - 分享处理方法
    
    /// 处理通用分享事件
    /// - Parameter shareData: 分享数据对象，包含imageUrl、text和isSound
    private func handleShare(shareData: ShareData) {
        ShareViewModel.presentShare(shareData: shareData, from: self)
    }
    
    /// 显示分享错误提示
    /// - Parameter message: 错误消息
    private func showShareErrorAlert(message: String) {
        let alert = UIAlertController(
            title: Language.share_failed,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: Language.share_ok, style: .default))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    /// 处理每日石头分享
    /// - Parameter id: 石头的唯一标识符
    private func handleDailyMushroomShare(id: String) {
        // 从 viewModel 获取石头信息
        if let stone = viewModel.getDailyMushroom(by: id) {
            let shareText = stone.name
            let shareData = ShareData(
                imageUrl: stone.photoUrl ?? "",
                text: shareText
            )
            ShareViewModel.presentShare(shareData: shareData, from: self)
        } else {
            // 如果找不到具体的石头信息，显示错误提示
            showShareErrorAlert(message: Language.share_stone_not_found)
        }
    }
}
