import UIKit
import SwiftUI
import AVFoundation
import Photos
import Combine

class RecognizeViewController: BaseHostingViewController<RecognizePage> {
    let viewModel = RecognizeViewModel()
    let actionModel = RecognizeActionModel()
    let loadingActionModel = IdentifyLoadingActionModel()
    let resultActionModel = IdentifyResultActionModel()
    private var cancellables = Set<AnyCancellable>()
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.cameraOpen, closeEventName: EventName.cameraClose)
    private var autoSaveToCollection: Bool = false
    private var autoSaveToWishList: Bool = false
    init() {
        super.init(rootView: RecognizePage(
            viewModel: viewModel,
            actionModel: self.actionModel,
            loadingActionModel: self.loadingActionModel,
            resultActionModel: self.resultActionModel
        ))
    }
    
    init(autoSaveToCollection: Bool = false, autoSaveToWishList: Bool = false) {
        self.autoSaveToCollection = autoSaveToCollection
        self.autoSaveToWishList = autoSaveToWishList
        super.init(rootView: RecognizePage(
            viewModel: viewModel,
            actionModel: self.actionModel,
            loadingActionModel: self.loadingActionModel,
            resultActionModel: self.resultActionModel
        ))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setActions()
        self.observeIdentificationResults()
    }
    
    private func setActions() {
        self.setCameraActions()
        self.setLoadingActions()
        self.setResultActions()
    }
    
    private func setCameraActions() {
        self.actionModel.onCloseClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.cameraCloseClick)
            guard let self else { return }
            self.dismiss(animated: true)
        }.store(in: &cancellables)
        
        self.actionModel.onCaptureClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.cameraShotClick)
            guard let self else { return }
            self.viewModel.capturePhoto()
        }.store(in: &cancellables)
        
        self.actionModel.onAlbumClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.cameraImportImageClick)
            guard let self else { return }
            self.viewModel.showingImagePicker = true
        }.store(in: &cancellables)
        
        self.actionModel.onImageSelected.sink { [weak self] image in
            guard let self else { return }
            self.viewModel.processSelectedImage(image)
        }.store(in: &cancellables)
        
        self.actionModel.onSnapTipClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.cameraTipsClick)
            guard let self else { return }
            self.viewModel.showTip()
        }.store(in: &cancellables)
    }
    
    private func setLoadingActions() {
        self.loadingActionModel.navBackClick.sink { [weak self] in
            guard let self else { return }
            FireBaseEvent.send(eventName: EventName.identifyingCloseClick)
            self.viewModel.reset()
        }.store(in: &cancellables)
        
        self.loadingActionModel.navCameraClick.sink { [weak self] in
            guard let self else { return }
            FireBaseEvent.send(eventName: EventName.identifyingRetakeClick)
            self.viewModel.reset()
        }.store(in: &cancellables)
    }
    
    private func setResultActions() {
        self.resultActionModel.navBackClick.sink { [weak self] in
            guard let self else { return }
            if (self.viewModel.needChangeResult()) {
                self.viewModel.changeResultApi { success in
                    if (success) {
                        FireBaseEvent.send(eventName: EventName.resultCloseClick, params: [EventParam.uid: self.viewModel.currentStone?.id ?? ""])
                        self.viewModel.reset()
                    } else {
                        ToastUtil.showToast(Language.change_result_failed)
                    }
                }
            } else {
                FireBaseEvent.send(eventName: EventName.resultCloseClick, params: [EventParam.uid: self.viewModel.currentStone?.id ?? ""])
                self.viewModel.reset()
            }
            
        }.store(in: &cancellables)
        
        self.resultActionModel.navCameraClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.resultRetakeClick, params: [EventParam.uid: self?.viewModel.currentStone?.id ?? "", EventParam.index:"0"])
            guard let self else { return }
            self.viewModel.reset()
        }.store(in: &cancellables)
        
        self.resultActionModel.onViewMoreImagesClick.sink { [weak self] imageUrls in
            guard let self else { return }
            // TODO: 111 viewMoreImages
        }.store(in: &cancellables)
        
        self.resultActionModel.bottomActionClick.sink { [weak self] actionType in
            guard let self else { return }
            switch actionType {
            case .save:
                self.handleSaveAction()
            case .addWish:
                self.handleAddWishAction()
            case .new:
                self.viewModel.reset()
            case .share:
                // 不在这里处理分享，让识别结果页面自己处理
                break
            }
        }.store(in: &cancellables)
        
        self.resultActionModel.onImageClick.sink { [weak self] (position, imageUrls) in
            guard let self else { return }
            ViewImageUtil.show(parent: self, position: position, imageUrls: imageUrls)
        }.store(in: &cancellables)
        self.resultActionModel.onChangeResultClick.sink { position in
            self.viewModel.changeResult(position:position)
        }.store(in: &cancellables)
    }
    
    // MARK: - 监听识别结果
    
    /// 监听识别结果，自动保存到收藏（如果需要）
    private func observeIdentificationResults() {
        // 监听识别状态变化，当状态变为result时检查是否需要自动保存
        viewModel.$identifyState
            .sink { [weak self] state in
                guard let self = self,
                      state == .result else { return }
//                if (self.autoSaveToCollection) {
//                    if let stone = self.viewModel.currentStone {
//                        self.autoSaveStoneToCollection(stone: stone)
//                    }
//                }
                if (self.autoSaveToWishList) {
                    if let stone = self.viewModel.currentStone{
                        handleAddWishAction(onlyAdd: true)
                    }
                }
                
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 保存收藏处理
    
    /// 自动保存石头到收藏
    private func autoSaveStoneToCollection(stone: Stone) {
        // 从识别结果中获取identificationId
        guard let identificationId = viewModel.identificationId else {
            print("❌ Invalid identification ID for auto-save")
            return
        }
        
        LocalRecordItem.addToCollectionOnly(identificationId: identificationId) { success in
            DispatchQueue.main.async {
                if success {
                    ToastUtil.showToast(Language.recognize_auto_saved_collection)
                    // 通知其他页面刷新收藏状态
                    NotificationCenter.default.post(name: .ReloadHistoryList, object: nil)
                }
                // 注意：自动保存失败时不显示错误提示，避免干扰用户体验
            }
        }
    }
    
    /// 处理保存收藏操作
    private func handleSaveAction() {
        // 根据识别模式获取相应的石头数据
        let stone: Stone?
        // 图片识别结果
        stone = viewModel.currentStone
        
        guard let stone = stone else {
            ToastUtil.showToast(Language.recognize_stone_loading)
            return
        }
        
        // 从识别结果中获取identificationId
        guard let identificationId = viewModel.identificationId else {
            ToastUtil.showToast(Language.recognize_invalid_id)
            return
        }
        if (viewModel.needChangeResult()) {
            viewModel.changeResultApi { success in
                if (success) {
                    LocalRecordItem.addToCollectionOnly(identificationId: identificationId) { success in
                        DispatchQueue.main.async {
                            if success {
                                ToastUtil.showToast(Language.recognize_added_collection_success)
                                self.viewModel.isInFavorite = true
                                // 通知其他页面刷新收藏状态
                                NotificationCenter.default.post(name: .ReloadHistoryList, object: nil)
                                self.viewModel.reset()
                            } else {
                                ToastUtil.showToast(Language.recognize_added_collection_failed)
                            }
                        }
                    }
                } else {
                    ToastUtil.showToast(Language.change_result_failed)
                }
            }
        } else {
            LocalRecordItem.addToCollectionOnly(identificationId: identificationId) { success in
                DispatchQueue.main.async {
                    if success {
                        ToastUtil.showToast(Language.recognize_added_collection_success)
                        self.viewModel.isInFavorite = true
                        // 通知其他页面刷新收藏状态
                        NotificationCenter.default.post(name: .ReloadHistoryList, object: nil)
                        self.viewModel.reset()
                    } else {
                        ToastUtil.showToast(Language.recognize_added_collection_failed)
                    }
                }
            }
        }
    }
    
    /// 处理添加到心愿单操作
    private func handleAddWishAction(onlyAdd:Bool = false) {
        
        if onlyAdd && viewModel.isInWish {
            return
        }
        // 根据识别模式获取相应的石头数据
        let stone: Stone?
        // 图片识别结果
        stone = viewModel.currentStone
        
        guard let stone = stone else {
            ToastUtil.showToast(Language.recognize_stone_loading_wait)
            return
        }
        if (viewModel.isInWish) {
            Task {
                do {
                    let req = DeleteWishRequest(stoneId: stone.id)
                    let result: DeleteWishResponse? = try await ApiRequest.requestAsync(request: req)
                    
                    DispatchQueue.main.async {
                        if result != nil {
                            ToastUtil.showToast(Language.recognize_delete_wishlist_success)
                            self.viewModel.isInWish = false
                            self.viewModel.currentItem?.isInWishlist = false
                            self.viewModel.identifyItems[self.viewModel.position].isInWishlist = false
                            // 通知其他页面刷新心愿单状态
                            NotificationCenter.default.post(name: .ReloadHistoryList, object: nil)
                        } else {
                            ToastUtil.showToast(Language.recognize_delete_wishlist_failed)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        ToastUtil.showToast(Language.recognize_delete_wishlist_failed)
                    }
                }
            }
        } else {
            Task {
                do {
                    let req = AddToWishListRequest(stoneId: stone.id)
                    let result: AddToWishListResponse? = try await ApiRequest.requestAsync(request: req)
                    
                    DispatchQueue.main.async {
                        if result != nil {
                            ToastUtil.showToast(Language.recognize_added_wishlist_success)
                            self.viewModel.isInWish = true
                            self.viewModel.currentItem?.isInWishlist = true
                            self.viewModel.identifyItems[self.viewModel.position].isInWishlist = true
                            // 通知其他页面刷新心愿单状态
                            NotificationCenter.default.post(name: .ReloadHistoryList, object: nil)
                        } else {
                            ToastUtil.showToast(Language.recognize_added_wishlist_failed)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        ToastUtil.showToast(Language.recognize_added_wishlist_failed)
                    }
                }
            }
        }
        
    }
}
