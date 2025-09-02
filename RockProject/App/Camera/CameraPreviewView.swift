import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    var onTapFocus: ((CGPoint, UIView) -> Void)? = nil

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        previewLayer.frame = UIScreen.main.bounds
//        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tap)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        let bounds = uiView.bounds
        if bounds.width > 0 && bounds.height > 0 {
            previewLayer.frame = bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTapFocus)
    }

    class Coordinator: NSObject {
        var onTap: ((CGPoint, UIView) -> Void)?

        init(onTap: ((CGPoint, UIView) -> Void)?) {
            self.onTap = onTap
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let point = gesture.location(in: gesture.view)
            if let view = gesture.view {
                onTap?(point, view)
            }
        }
    }
}
