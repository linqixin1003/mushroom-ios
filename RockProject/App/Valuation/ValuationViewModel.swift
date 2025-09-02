import Foundation
import Combine
import UIKit
import Photos

enum ValuationState {
    case idle
    case loading
    case error
    case result
}

class ValuationViewModel: ObservableObject {

    let cameraViewModel: CameraViewModel = CameraViewModel()
    @Published var showSnapTip = false
    @Published var valuationState: ValuationState = .idle
    @Published var showingImagePicker = false

    // 输入/输出
    var currentImage: UIImage? = nil
    @Published var result: ValuationResponse? = nil

    func reset() {
        self.valuationState = .idle
        self.result = nil
        self.currentImage = nil
        self.showingImagePicker = false
    }

    func showTip() {
        showSnapTip = true
    }

    func processSelectedImage(_ image: UIImage) {
        self.valuation(image: image)
    }

    func capturePhoto() {
        self.cameraViewModel.capturePhoto { [weak self] image in
            guard let self, let image else { return }
            self.valuation(image: image)
        }
    }

    func valuation(image: UIImage) {
        self.currentImage = image
        self.valuationState = .loading
        Task {
            let response = await self.uploadAndValuate(image: image)
            await MainActor.run {
                if let response = response {
                    self.result = response
                    self.valuationState = .result
                    if PersistUtil.autoSaveImage {
                        self.cameraViewModel.saveCapturedImage()
                    }
                } else {
                    self.valuationState = .error
                }
            }
        }
    }

    private func uploadAndValuate(image: UIImage) async -> ValuationResponse? {
        guard let data = try? image.toAPIData() else {
            return nil
        }
        let req = ValuationRequest(image: data)
        do {
            let resp: ValuationResponse = try await ApiRequest.requestAsync(request: req)
            return resp
        } catch {
            print("❌ Valuation failed: \(error)")
            return nil
        }
    }

    private func saveImageToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    if let error = error {
                        print("Save photo error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}