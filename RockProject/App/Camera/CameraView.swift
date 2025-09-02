import SwiftUI
import AVFoundation

struct CameraView: View {
    let tips:String
    @ObservedObject var viewModel: CameraViewModel

    var body: some View {
        ZStack {
            CameraPreviewView(previewLayer: viewModel.previewLayer) { point, view in
                viewModel.focus(at: point, in: view)
            }
            if !viewModel.isAuthorized {
                VStack {
                    Text(Language.camera_permission_request_desc)
                        .font(.regular(14.rpx))
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(Language.camera_go_button) {
                        FireBaseEvent.send(eventName: EventName.cameraPermissionGoClick, params: [EventParam.type: "1"])
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }
                    .font(.regular(20.rpx))
                    .foregroundColor(.white)
                    .frame(width: 200.rpx, height: 40.rpx)
                    .background(Color.primary)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color.black)
            } else {
                Button {
                    FireBaseEvent.send(eventName: EventName.cameraFlashClick, params: [EventParam.isOpen: (viewModel.isFlashOn ? "1" : "0")])
                    self.viewModel.toggleFlash()
                } label: {
                    // TODO: update icon
                    Image(viewModel.isFlashOn ? "icon_camera_flash_off_32" : "icon_camera_flash_off_32")
                        .frame(width: 32.rpx, height: 32.rpx)
                }
                .padding(.top, SafeTop)
                .padding(.trailing, 16.rpx)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                
                VStack {
                    Spacer()
                    Text(tips)
                        .font(.regular(14.rpx))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    ZoomSlider(zoomFactor: $viewModel.zoomFactor)
                }
            }
        }
        .onAppear {
            viewModel.checkCameraAuthorization()
        }
        .onChange(of: viewModel.zoomFactor) { factor in
            viewModel.zoom(to: factor)
        }
    }
}

// MARK: - ZoomSlider
struct ZoomSlider: View {
    @Binding var zoomFactor: CGFloat
    
    var body: some View {
        HStack(spacing: 10) {
            Slider(value: $zoomFactor, in: 1...5, step: 0.1) {
                Text(Language.camera_zoom)
            } minimumValueLabel: {
                Text("-")
                    .font(.bold(24.rpx))
                    .foregroundColor(.white)
            } maximumValueLabel: {
                Text("+")
                    .font(.bold(24.rpx))
                    .foregroundColor(.white)
            }
            .frame(width: 160)
            .accentColor(.white)
            .padding()
        }
    }
}
