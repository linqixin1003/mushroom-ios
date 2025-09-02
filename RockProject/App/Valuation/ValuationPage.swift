import UIKit
import SwiftUI
import AVFoundation
import Photos
import Combine

struct ValuationActionModel {
    let onCloseClick = PassthroughSubject<Void, Never>()
    let onCaptureClick = PassthroughSubject<Void, Never>()
    let onAlbumClick = PassthroughSubject<Void, Never>()
    let onImageSelected = PassthroughSubject<UIImage, Never>()
    let onSnapTipClick = PassthroughSubject<Void, Never>()
}

struct ValuationPage: View {
    @ObservedObject var viewModel: ValuationViewModel
    let actionModel: ValuationActionModel
    let loadingActionModel: ValuationLoadingActionModel
    let resultActionModel: ValuationResultActionModel

    @State private var selectedImage: UIImage?

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                CameraView(tips: Language.valuation_camera_tips, viewModel: self.viewModel.cameraViewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                RecognizeBottomView(
                    onAlbumClick: {
                        self.actionModel.onAlbumClick.send()
                    },
                    onCaptureClick: {
                        self.actionModel.onCaptureClick.send()
                    },
                    onTipsClick: {
                        self.actionModel.onSnapTipClick.send()
                    }
                )
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Button {
                self.actionModel.onCloseClick.send()
            } label: {
                Image("icon_camera_close_32")
                    .frame(width: 32.rpx, height: 32.rpx)
            }
            .padding(.top, SafeTop)
            .padding(.leading, 16.rpx)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .sheet(isPresented: $viewModel.showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, didSelectImage: { image in
                self.actionModel.onImageSelected.send(image)
            })
        }
        .fullScreenCover(isPresented: .constant(viewModel.valuationState == .result)) {
            if let result = viewModel.result {
                ValuationResultPage(
                    result: result,
                    capturedImage: viewModel.currentImage,
                    actionModel: resultActionModel
                )
            }
        }
        .overlay(
            Group {
                if self.viewModel.valuationState == .loading || self.viewModel.valuationState == .error {
                    ValuationLoadingPage(viewModel: self.viewModel, actionModel: loadingActionModel)
                }
                if viewModel.showSnapTip {
                    SnapTipView(
                        onCloseClick: {
                            viewModel.showSnapTip = false
                        },
                        onOKClick: {
                            FireBaseEvent.send(eventName: EventName.cameraTipsOkClick)
                            viewModel.showSnapTip = false
                        }
                    )
                    .animation(.easeInOut(duration: 0.3))
                }
            }
        )
    }
}
