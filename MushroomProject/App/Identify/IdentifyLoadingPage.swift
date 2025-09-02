import SwiftUI
import Combine

struct IdentifyLoadingActionModel {
    let navBackClick = PassthroughSubject<Void, Never>()
    let navCameraClick = PassthroughSubject<Void, Never>()
}

struct IdentifyLoadingPage: View {
    @ObservedObject var viewModel:RecognizeViewModel
    let actionModel: IdentifyLoadingActionModel
    
    @State private var progress: Int = 1
    @State private var timer: Timer?
    @State private var startTime: Date?
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.identifyingOpen, closeEventName: EventName.identifyingClose)
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Image(uiImage: self.viewModel.currentImage ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 240.rpx)
                
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                        .frame(height: 30.rpx)
                    if self.viewModel.identifyState == .error {
                        Text(Language.identify_recognition_failed)
                            .font(.regular(14.rpx))
                            .lineSpacing(2.rpx)
                            .foregroundColor(.appTextLight)
                    } else {
                        Text(Language.identify_wait_moment)
                            .font(.regular(14.rpx))
                            .lineSpacing(2.rpx)
                            .foregroundColor(.appTextLight)
                        
                        Spacer()
                            .frame(height: 8.rpx)
                        
                        Text("\(progress)%")
                            .font(.regular(14.rpx))
                            .lineSpacing(2.rpx)
                            .foregroundColor(.appTextLight)
                    }
                    Spacer()
                        .frame(height: 48.rpx)
                    
                    Image("icon_identify_loading_180")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180.rpx, height: 180.rpx)
                    
                    if viewModel.identifyState == .error {
                        Button("Retry") {
                            FireBaseEvent.send(eventName: EventName.identifyingRetakeClick)
                            viewModel.identifyState = .idle
                            self.startProgressSimulation(duration:5.0)
                            viewModel.identify(image: viewModel.currentImage!)
                        }
                        .frame(width: 100.rpx, height:40.rpx)
                        .background(Color.primary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .clipShape(RoundedCorner(radius: 16.rpx, corners: [.topLeft, .topRight]))
                .padding(.top, -16.rpx)
            }
            // TopNavBar
            HStack {
                Button {
                    self.actionModel.navBackClick.send()
                } label: {
                    Image("icon_camera_close_32")
                        .frame(width: 32.rpx, height: 32.rpx)
                }
                
                Spacer()
                
                Button {
                    self.actionModel.navCameraClick.send()
                } label: {
                    Image("icon_camera_retake_32")
                        .frame(width: 32.rpx, height: 32.rpx)
                }
            }
            .padding(.top, SafeTop)
            .padding(.horizontal, 16.rpx)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            startProgressSimulation(duration: 5.0)
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
            startTime = nil
        }
    }
    
    private func startProgressSimulation(duration: TimeInterval) {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let startTime = startTime else { return }
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            let progressPercentage = min(elapsedTime / duration, 1.0)
            
            let easedProgress = easeInOutQuad(progressPercentage)
            progress = Int(1 + easedProgress * 97) // 从1%到98%
            
            if progress >= 98 {
                timer?.invalidate()
                timer = nil
                self.startTime = nil
            }
        }
    }
    
    // 缓动函数：开始和结束缓慢，中间快速
    private func easeInOutQuad(_ t: Double) -> Double {
        if t < 0.5 {
            return 2 * t * t
        } else {
            return 1 - pow(-2 * t + 2, 2) / 2
        }
    }
}
