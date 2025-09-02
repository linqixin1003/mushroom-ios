import Foundation
import SnapKit
import Combine
import SwiftUI

class ProfileViewController: TabItemViewController {
    let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.profileOpen, closeEventName: EventName.profileClose)
    private let viewModel = ProfileViewModel()
    private let actionModel = ProfileActionModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func realDidLoad() {
        super.realDidLoad()
        self.setActions()
        self.observeNotifications()
    }
    
    override func loadUI(completion: @escaping (Bool) -> ()) {
        self.setupUI()
        self.viewModel.loadData { [weak self] success in
            guard self != nil else { return }
            completion(success)
        }
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
        self.actionModel.shareClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.mineShareClick)
            guard let self else { return }
            let activityViewController = UIActivityViewController(activityItems: [Config.shareAppUrl!], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }.store(in: &cancellables)
        
        self.actionModel.settingsClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.mineSettingClick)
            guard let self else { return }
            self.navigationController?.pushViewController(SettingViewController(), animated: true)
        }.store(in: &cancellables)
        
        self.actionModel.onVipBannerClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.mineVipClick)
            guard let self else { return }
            ConvertViewController.present()
        }.store(in: &cancellables)

        self.actionModel.onItemClick.sink { [weak self] data in
            FireBaseEvent.send(eventName: EventName.mineItemClick, params: [EventParam.uid:data.uid])
            guard let self else { return }
            let vc = if (data.identificationId == nil) {
                DetailViewController(id: data.uid, imageUrl: data.url, type: data.type)
            } else {
                DetailViewController(id: data.uid, imageUrl: data.url, type: data.type, identificationId: data.identificationId!)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }.store(in: &cancellables)

        self.actionModel.onAddMoreClick.sink { [weak self] selectedTab in
            FireBaseEvent.send(eventName: EventName.mineAddMoreClick)
            guard let self else { return }
            self.handleAddMoreAction(selectedTab: selectedTab)
        }.store(in: &cancellables)
    }
    
    private func observeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: .ReloadHistoryList, object: nil)
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
    private func loadData() {
        self.viewModel.loadData { [weak self] success in
            guard self != nil else { return }
            debugPrint("[ProfileVIewControllser] loadData - success: \(success)")
        }
    }
    
    private lazy var contentView: ProfilePage = {
        let view = ProfilePage(viewModel: self.viewModel, actionModel: self.actionModel)
        return view
    }()
    
    // MARK: - Add More Action
    
    /// 处理加号按钮点击 - 启动相机拍照
    /// - Parameter selectedTab: 当前选中的tab（0: 收藏, 1,心愿单, 2: 历史）
    private func handleAddMoreAction(selectedTab: Int) {
        // 只有在"My Collection"页面（selectedTab == 0）时才自动保存到收藏
        let shouldAutoSave = (selectedTab == 0)
        let shouldAutoAddWish = (selectedTab == 1)
        let vc = RecognizeViewController(autoSaveToCollection: shouldAutoSave, autoSaveToWishList: shouldAutoAddWish)
        
        // 尝试通过 TabBarController 来 present，如果没有则直接在当前视图控制器上 present
        if let tabbarController = TabBarController.tabBarController {
            tabbarController.present(vc, animated: true)
        } else {
            self.present(vc, animated: true)
        }
    }
}
