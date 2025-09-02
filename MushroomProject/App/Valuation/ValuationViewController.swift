import UIKit
import SwiftUI
import AVFoundation
import Photos
import Combine

class ValuationViewController: BaseHostingViewController<ValuationPage> {
    let viewModel = ValuationViewModel()
    let actionModel = ValuationActionModel()
    let loadingActionModel = ValuationLoadingActionModel()
    let resultActionModel = ValuationResultActionModel()
    private var cancellables = Set<AnyCancellable>()
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.valuatingOpen, closeEventName: EventName.valuatingClose)

    init() {
        super.init(rootView: ValuationPage(
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
    }

    private func setActions() {
        self.setCameraActions()
        self.setLoadingActions()
        self.setResultActions()
    }

    private func setCameraActions() {
        self.actionModel.onCloseClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.cameraCloseClick)
            self?.dismiss(animated: true)
        }.store(in: &cancellables)

        self.actionModel.onCaptureClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.cameraShotClick)
            self?.viewModel.capturePhoto()
        }.store(in: &cancellables)

        self.actionModel.onAlbumClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.cameraImportImageClick)
            self?.viewModel.showingImagePicker = true
        }.store(in: &cancellables)

        self.actionModel.onImageSelected.sink { [weak self] image in
            self?.viewModel.processSelectedImage(image)
        }.store(in: &cancellables)

        self.actionModel.onSnapTipClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.cameraTipsClick)
            self?.viewModel.showTip()
        }.store(in: &cancellables)
    }

    private func setLoadingActions() {
        self.loadingActionModel.navBackClick.sink { [weak self] in
            // 关闭估价中，回到相机
            FireBaseEvent.send(eventName: EventName.valuatingCloseClick)
            self?.viewModel.reset()
        }.store(in: &cancellables)

        self.loadingActionModel.navCameraClick.sink { [weak self] in
            // 重拍
            FireBaseEvent.send(eventName: EventName.valuatingRetakeClick)
            self?.viewModel.reset()
        }.store(in: &cancellables)
    }

    private func setResultActions() {
        self.resultActionModel.navBackClick.sink { [weak self] in
            // 关闭结果页，回到相机
            FireBaseEvent.send(eventName: EventName.valuationResultCloseClick, params: [:])
            self?.viewModel.reset()
        }.store(in: &cancellables)
        self.resultActionModel.viewFullImage.sink{ [weak self] in
            guard let self else { return }
            
            ViewImageUtil.show(parent: self, position: 0, imageUrls: [viewModel.currentImage!])
            
        }.store(in: &cancellables)
    }
}
