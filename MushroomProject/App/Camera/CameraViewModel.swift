import AVFoundation
import SwiftUI

class CameraViewModel: ObservableObject {
    private let service = CameraService()

    @Published var isAuthorized = false
    @Published var isFlashOn: Bool = false
    @Published var capturedImage: UIImage?
    @Published var zoomFactor: CGFloat = 1.0

    var previewLayer: AVCaptureVideoPreviewLayer {
        service.previewLayer
    }

    func capturePhoto(completion: ((UIImage?) -> Void)? = nil) {
        if (isAuthorized == false) {return}
        service.capturePhoto { [weak self] image in
            DispatchQueue.main.async {
                self?.capturedImage = image
                completion?(image)
            }
        }
    }

    func toggleFlash() {
        service.toggleFlash()
        isFlashOn = service.isFlashOn
    }

    func zoom(to factor: CGFloat) {
        zoomFactor = factor
        service.zoom(to: factor)
    }

    func focus(at point: CGPoint, in view: UIView) {
        service.focus(at: point, in: view)
    }
    
    func switchCamera() {
        service.switchCamera()
    }

    func saveCapturedImage() {
        if let image = capturedImage {
            service.savePhotoToLibrary(image)
            ToastUtil.showToast("save success")
            capturedImage = nil
        }
    }

    func cancelPreview() {
        capturedImage = nil
    }
    
    func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isAuthorized = true
        case .notDetermined:
            requestCameraAccess()
        case .denied, .restricted:
            self.isAuthorized = false
        @unknown default:
            self.isAuthorized = false
        }
    }
    
    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if granted {
                    self?.service.setupSession()
                }
            }
        }
    }
}
