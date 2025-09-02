import UIKit
import SwiftUI
import Combine
import Lightbox
class DetailViewController: BaseHostingViewController<DetailPage> {
    
    let viewModel = DetailViewModel()
    let actionModel = DetailActionModel()
    
    private var cancellables = Set<AnyCancellable>()
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.detailOpen, closeEventName: EventName.detailClose)
    init(id: String) {
        self.viewModel.id = id
        super.init(rootView: DetailPage(viewModel: self.viewModel, actionModel: self.actionModel), title: Language.detail_page_title)
    }
    
    init(id: String, imageUrl: String, type: LocalRecordType) {
        self.viewModel.id = id
        self.viewModel.headerImageUrl = imageUrl
        self.viewModel.mediaType = type
        super.init(rootView: DetailPage(viewModel: self.viewModel, actionModel: self.actionModel), title: Language.detail_page_title)
    }
    
    init(id: String, imageUrl: String, type: LocalRecordType, identificationId:Int) {
        self.viewModel.id = id
        self.viewModel.headerImageUrl = imageUrl
        self.viewModel.mediaType = type
        self.viewModel.identificationId = identificationId
        super.init(rootView: DetailPage(viewModel: self.viewModel, actionModel: self.actionModel), title: Language.detail_page_title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setActions()
        self.observeNotifications()
        self.viewModel.loadData()
    }
    
    private func setActions() {
        self.actionModel.navBackClick.sink { [weak self] in
            guard let self else { return }
            FireBaseEvent.send(eventName: EventName.detailCloseClick, params: [EventParam.uid: self.viewModel.id])
            self.navigationController?.popViewController(animated: true)
        }.store(in: &cancellables)
        
        self.actionModel.navCameraClick.sink { [weak self] in
            guard let self else { return }
            // TODO: capture
        }.store(in: &cancellables)
        
        self.actionModel.onViewMoreImagesClick.sink { [weak self] imageUrls in
            guard let self else { return }
            // TODO: actions
        }.store(in: &cancellables)
        
        self.actionModel.bottomActionClick.sink { [weak self] type in
            guard let self else { return }
            switch type {
            case .save:
                FireBaseEvent.send(eventName: EventName.detailSaveClick, params: [EventParam.uid: self.viewModel.id])
                self.handleSaveAction()
            case .new:
                FireBaseEvent.send(eventName: EventName.detailRetakeClick, params: [EventParam.uid: self.viewModel.id, EventParam.index: "1"])
                self.handleNewAction()
            case .share:
                FireBaseEvent.send(eventName: EventName.detailShareClick, params: [EventParam.uid: self.viewModel.id])
                self.handleShareAction()
            }
        }.store(in: &cancellables)
        
        self.actionModel.onImageClick.sink { [weak self] (position, imageUrl) in
            guard let self else { return }
            ViewImageUtil.show(parent: self, position: position, imageUrls: imageUrl)
        }.store(in: &cancellables)
    }
    
    override func observeNotifications() {
        // 监听语言变化通知
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: LocalizationManager.languageChangedNotification, object: nil)
    }
    
    @objc
    private func languageChanged() {
        // 强制刷新SwiftUI视图
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 重新创建rootView以应用新的语言
            let newRootView = DetailPage(viewModel: self.viewModel, actionModel: self.actionModel)
            self.rootView = newRootView
            self.hostingController.rootView = newRootView
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 保存收藏处理
    
    /// 处理保存收藏操作
    private func handleSaveAction() {
        guard let mushroom = viewModel.mushroom else {
            ToastUtil.showToast(Language.detail_mushroom_loading)
            return
        }
        if !viewModel.canCollection() {
            return
        }
        Task {
            do {
                let req = CollectionAddRequest(identificationId: viewModel.identificationId!)
                let result: CollectionAddResponse = try await ApiRequest.requestAsync(request: req)
                
                DispatchQueue.main.async {
                    if result.success {
                        ToastUtil.showToast(Language.detail_collected)
                        self.viewModel.isInFavorite = true
                        // 通知其他页面刷新心愿单状态
                        NotificationCenter.default.post(name: .ReloadHistoryList, object: nil)
                    } else {
                        ToastUtil.showToast(result.message.isEmpty ? Language.detail_collected_failed : result.message)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    ToastUtil.showToast(Language.detail_collected_error)
                }
            }
        }
        
//        let simpleMushroom = mushroom.toSimpleMushroom()
//
//        LocalRecordItem.addToCollectionOnly(mushroom: simpleMushroom) { [weak self] success in
//            DispatchQueue.main.async {
//                if success {
//                    ToastUtil.showToast("Added to collection successfully")
//                    // 通知其他页面刷新收藏状态
//                    NotificationCenter.default.post(name: .ReloadHistoryList, object: nil)
//                } else {
//                    ToastUtil.showToast("Failed to add to collection, please try again")
//                }
//            }
//        }
    }
    
    /// 处理新建操作（打开相机 By Photo 模式）
    private func handleNewAction() {
        let vc = RecognizeViewController()
        
        // 尝试通过 TabBarController 来 present，如果没有则直接在当前视图控制器上 present
        if let tabbarController = TabBarController.tabBarController {
            tabbarController.present(vc, animated: true)
        } else {
            self.present(vc, animated: true)
         }
     }
     
     /// 处理分享操作
     private func handleShareAction() {
         guard let mushroom = viewModel.mushroom else {
             ToastUtil.showToast(Language.detail_mushroom_loading)
             return
         }
         
         // 使用头图（第一张图片）和石头名称
         let imageUrl = mushroom.imageUrl
         let shareText = mushroom.name
         
         let shareData = ShareData(
             imageUrl: imageUrl,
             text: shareText
         )
         
         ShareViewModel.presentShare(shareData: shareData, from: self)
     }
}
