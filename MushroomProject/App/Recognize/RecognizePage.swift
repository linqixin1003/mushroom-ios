import UIKit
import SwiftUI
import AVFoundation
import Photos
import Combine

struct RecognizeActionModel {
    let onCloseClick = PassthroughSubject<Void, Never>()
    let onCaptureClick = PassthroughSubject<Void, Never>()
    let onAlbumClick = PassthroughSubject<Void, Never>()
    let onImageSelected = PassthroughSubject<UIImage, Never>()
    let onSnapTipClick = PassthroughSubject<Void, Never>()
}

struct RecognizePage: View {
    @ObservedObject var viewModel: RecognizeViewModel
    let actionModel: RecognizeActionModel
    let loadingActionModel: IdentifyLoadingActionModel
    let resultActionModel: IdentifyResultActionModel
    
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                CameraView(tips: Language.camera_preview_tip, viewModel: self.viewModel.cameraViewModel)
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
        .fullScreenCover(isPresented: .constant(viewModel.identifyState == .result)) {
            if let currentMushroom = viewModel.currentMushroom{
                let images = viewModel.identifyItems.map { identifyItem in
                    identifyItem.mushroom.photos?.first.map { mushroomPhoto in
                        mushroomPhoto.url ?? ""
                    } ?? ""
                }
                
                IdentifyResultPage(mushroom: currentMushroom,
                                   images: images,
                                   isInWish: viewModel.isInWish,
                                   isInFavorite: viewModel.isInFavorite,
                                   actionModel: resultActionModel,
                                   capturedImage: viewModel.currentImage)
            }
        }
        .overlay(
            Group {
                if self.viewModel.identifyState == .loading || self.viewModel.identifyState == .error {
                    IdentifyLoadingPage(viewModel: self.viewModel, actionModel: loadingActionModel)
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

