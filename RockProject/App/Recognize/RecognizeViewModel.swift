import Foundation
import Combine
import AVFoundation
import UIKit
import Photos

enum IdentifyState {
    case idle
    case loading
    case error
    case result
}

class RecognizeViewModel: ObservableObject {
    
    let cameraViewModel: CameraViewModel = CameraViewModel()
    @Published var showSnapTip = false
    @Published var identifyState: IdentifyState = .idle
    @Published var showingImagePicker = false
    @Published var isInWish:Bool = false
    @Published var isInFavorite:Bool = false
    var currentImage: UIImage? = nil
    
    var identifyResult: IdentifyResponse? = nil
    
    @Published var position:Int = 0
    @Published var identifyItems: [IdentifyItem] = []
    @Published var currentItem: IdentifyItem? = nil
    @Published var currentStone: Stone? = nil
    var identificationId: Int? = nil
    var confidence:Double = 1.0
    
    func needChangeResult()->Bool{
        return self.position > 0
    }
    func changeResult(position: Int) {
        self.position = position
        self.currentItem = self.identifyItems[position]
        self.currentStone = self.currentItem!.stone
        self.isInWish = self.currentItem!.isInWishlist
        self.isInFavorite = self.currentStone!.isFavorite
    }
    
    func reset() {
        self.identifyState = .idle
        self.identifyResult = nil
        self.currentImage = nil
    }
    
    func processSelectedImage(_ image: UIImage) {
        self.identify(image: image)
    }
    
    func showTip() {
        showSnapTip = true
    }
    
    func capturePhoto() {
        self.cameraViewModel.capturePhoto { [weak self] image in
            guard let self, let image else {
                return
            }
            self.identify(image: image)
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
    
    func changeResultApi(callBack: @escaping (Bool)->Void) {
        if (self.identificationId == nil || self.currentStone == nil) {
            callBack(false)
            return
        }
        
        Task {
            let req = ChangeResultRequest(
                identificationId: self.identificationId!, newStoneId: self.currentStone!.id, confidence: self.confidence
            )
            do {
                let response: ChangeResultResponse? = try await ApiRequest.requestAsync(request: req)
                await MainActor.run {
                    callBack(response != nil)
                }
            } catch {
                print("IdentifyResponse failed: \(error)")
                await MainActor.run {
                    callBack(false)
                }
            }
        }
    }
}

extension RecognizeViewModel {
    
    func identify(image: UIImage) {
        self.currentImage = image
        self.identifyState = .loading
        Task {
            let response = await self.compressAndIdentifyAsync(image: image)
            await MainActor.run {
                self.identifyResult = response
                self.identifyState = (response != nil && response!.results.isNotEmpty) ? .result : .error
                if self.identifyState  == .result {
                    self.identifyItems = Array(response!.results.prefix(3))
                    changeResult(position: 0)
                    self.identificationId = self.identifyItems.first?.identificationId
                    self.confidence = self.identifyItems.first?.confidence ?? 1.0
                    NotificationCenter.default.post(name: .ReloadHistoryList, object: nil)
                    if PersistUtil.autoSaveImage {
                        cameraViewModel.saveCapturedImage()
                    }
                    
                    // 识别成功后检查是否需要弹出求好评
                    AppReviewManager.shared.checkAndRequestReviewAfterIdentification()
                }
            }
        }
    }
    
    private func compressAndIdentifyAsync(image: UIImage) async -> IdentifyResponse? {
        guard let compressedData = try? image.toAPIData() else {
            return nil
        }
        let req = IdentifyRequest(
            image: compressedData,
            source: "camera",
            longitude: LocationManager.longitude,
            latitude: LocationManager.latitude,
            lang: "en"
        )
        do {
            let response: IdentifyResponse = try await ApiRequest.requestAsync(request: req)
            print("✅ IdentifyResponse success: \(response)")
            return response
        } catch {
            print("❌ IdentifyResponse failed: \(error)")
            
            // 如果是解码错误，打印更详细的信息
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("🔍 Type mismatch: Expected \(type), at path: \(context.codingPath)")
                    print("🔍 Debug description: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("🔍 Value not found: \(type), at path: \(context.codingPath)")
                    print("🔍 Debug description: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("🔍 Key not found: \(key), at path: \(context.codingPath)")
                    print("🔍 Debug description: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("🔍 Data corrupted at path: \(context.codingPath)")
                    print("🔍 Debug description: \(context.debugDescription)")
                @unknown default:
                    print("🔍 Unknown decoding error: \(decodingError)")
                }
            }
            
            return nil
        }
    }
}
