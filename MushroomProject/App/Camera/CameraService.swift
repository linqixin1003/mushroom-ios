import AVFoundation
import UIKit

class CameraService: NSObject, ObservableObject {
    private(set) var isFlashOn = false
    private(set) var previewLayer = AVCaptureVideoPreviewLayer()
    private let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var currentPosition: AVCaptureDevice.Position = .back
    private var photoCaptureDelegate: PhotoCaptureDelegate?

    override init() {
        super.init()
        setupSession()
    }

    func setupSession() {
        print("[CameraService] Start configure...")
        sessionQueue.async {
            do {
                self.session.beginConfiguration()
                self.session.sessionPreset = .photo

                guard let device = self.getDevice(position: self.currentPosition) else {
                    print("[CameraService] Failed to get camera device")
                    return
                }

                let videoInput = try AVCaptureDeviceInput(device: device)
                guard self.session.canAddInput(videoInput) else {
                    print("[CameraService] Failed to add video input")
                    return
                }

                self.videoDeviceInput = videoInput
                self.session.addInput(videoInput)

                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                } else {
                    print("[CameraService] Failed to add photo output")
                    return
                }

                self.previewLayer.session = self.session
                self.previewLayer.videoGravity = .resizeAspectFill

                self.session.commitConfiguration()
                self.session.startRunning()
            } catch {
                print("[CameraService] Camera configuration failed: \(error)")
            }
        }
    }

    func switchCamera() {
        print("[CameraService] switchCamera()")
        sessionQueue.async {
            guard let currentInput = self.videoDeviceInput else { return }
            self.session.beginConfiguration()
            self.session.removeInput(currentInput)

            self.currentPosition = self.currentPosition == .back ? .front : .back

            if let newDevice = self.getDevice(position: self.currentPosition),
               let newInput = try? AVCaptureDeviceInput(device: newDevice),
               self.session.canAddInput(newInput) {
                self.videoDeviceInput = newInput
                self.session.addInput(newInput)
            } else {
                self.session.addInput(currentInput)
            }

            self.session.commitConfiguration()
        }
    }

    func zoom(to factor: CGFloat) {
        sessionQueue.async {
            guard let device = self.videoDeviceInput?.device else { return }
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
                device.unlockForConfiguration()
            } catch {
                print("Zoom failed: \(error)")
            }
        }
    }

    func toggleFlash() {
        isFlashOn.toggle()
    }

    func focus(at point: CGPoint, in view: UIView) {
        let viewSize = view.bounds.size
        let focusPoint = CGPoint(x: point.y / viewSize.height, y: 1.0 - point.x / viewSize.width)
        
        sessionQueue.async {
            guard let device = self.videoDeviceInput?.device else { return }
      
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = .autoExpose
                }
                device.unlockForConfiguration()
            } catch {
                print("Focus error: \(error)")
            }
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        
        photoCaptureDelegate = PhotoCaptureDelegate(completion: { [weak self] image in
            completion(image)
            self?.photoCaptureDelegate = nil
        })
        
        photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate!)
    }
    
    func savePhotoToLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    private func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices.first
    }
}

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            completion(nil)
            return
        }
        completion(image)
    }
}
