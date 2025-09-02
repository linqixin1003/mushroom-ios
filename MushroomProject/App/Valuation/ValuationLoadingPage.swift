import SwiftUI
import Combine

struct ValuationLoadingActionModel {
    let navBackClick = PassthroughSubject<Void, Never>()
    let navCameraClick = PassthroughSubject<Void, Never>()
}

struct ValuationLoadingPage: View {
    @ObservedObject var viewModel: ValuationViewModel
    let actionModel: ValuationLoadingActionModel

    // 步骤进度：0~3，对应 3 个阶段
    @State private var step: Int = 0
    @State private var timer: Timer?
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.valuatingOpen, closeEventName: EventName.valuatingClose)

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if viewModel.valuationState == .error {
                // 未找到石头页
                notFoundContent
            } else {
                // 估价进行中页
                inProgressContent
            }

            // 顶部关闭按钮（两种态统一）
            topBar
        }
        .onAppear {
            if viewModel.valuationState != .error {
                startStepSimulation()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                actionModel.navBackClick.send()
            } label: {
                Image("icon_close2")
                    .frame(width: 32.rpx, height: 32.rpx)
            }
            Spacer()
        }
        .padding(.top, SafeTop)
        .padding(.horizontal, 32.rpx)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(true)
        .frame(maxHeight: .infinity, alignment: .top)
        .zIndex(10)
    }

    // MARK: - In Progress
    private var inProgressContent: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 16.rpx)

            // 内容容器（上圆角白底）
            VStack(spacing: 0) {
                // 图片区域（居中展示）
                ZStack {
                    if let image = viewModel.currentImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12.rpx)
                            .padding(.horizontal, 24.rpx)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.top, 24.rpx)
                Spacer().frame(height: 24.rpx)

                Text(Language.valuation_in_progress + "...")
                    .font(.system(size: 16.rpx, weight: .semibold))
                    .foregroundColor(.appText)
                    .padding(.horizontal, 20.rpx)
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer().frame(height: 24.rpx)

                // 三步进度
                VStack(alignment: .leading, spacing: 24.rpx) {
                    ValuationProgressItem(text: Language.valuation_step_identification, isFinish: step > 0)
                    ValuationProgressItem(text: Language.valuation_step_quality_evaluation, isFinish: step > 1)
                    ValuationProgressItem(text: Language.valuation_step_market_price_search, isFinish: step > 2)
                }
                Spacer().frame(height: 48.rpx)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedCorner(radius: 16.rpx, corners: [.topLeft, .topRight]))
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Not Found
    private var notFoundContent: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // 顶部全宽图
                if let image = viewModel.currentImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 220.rpx)
                        .clipped()
                } else {
                    Color.black.opacity(0.05)
                        .frame(height: 220.rpx)
                }

                // 白底圆角内容
                VStack(spacing: 0) {
                    Spacer().frame(height: 24.rpx)

                    Text(Language.valuation_not_found)
                        .font(.system(size: 20.rpx, weight: .bold))
                        .foregroundColor(.appText)
                        .padding(.horizontal, 20.rpx)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer().frame(height: 16.rpx)
                    // 拍摄技巧（简化版）
                    ScrollView {
                        SnapTipsContentView().padding(.horizontal, 42.rpx)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // 底部重拍按钮
                    VStack {
                        Button {
                            actionModel.navCameraClick.send()
                        } label: {
                            Text(Language.camera_retake)
                                .font(.system(size: 16.rpx))
                                .foregroundColor(.white)
                                .frame(maxWidth: 300.rpx)
                                .frame(height: 48.rpx)
                                .background(
                                    LinearGradient(
                                        colors: [Color.primary, Color.primary.opacity(0.6)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                        }
                    }
                    .frame(height: 80.rpx)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedCorner(radius: 16.rpx, corners: [.topLeft, .topRight]))
                .padding(.top, -16.rpx)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .ignoresSafeArea()
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8.rpx) {
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 6.rpx, height: 6.rpx)
                .foregroundColor(.secondary)
                .padding(.top, 6.rpx)
            Text(text)
                .font(.system(size: 14.rpx))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Step simulation
    private func startStepSimulation() {
        stopTimer()
        step = 0
        // 模拟 3 步进度，约 6 秒完成
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { t in
            if step < 2 {
                step += 1
            } else {
                t.invalidate()
                timer = nil
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Progress Item
private struct ValuationProgressItem: View {
    let text: String
    let isFinish: Bool

    var body: some View {
        HStack(spacing: 16.rpx) {
            if isFinish {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 16.rpx, height: 16.rpx)
                    .foregroundColor(.primary)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.appTextLight)
                    .frame(width: 16.rpx, height: 16.rpx)
            }

            Text(text)
                .font(.system(size: 14.rpx, weight: .medium))
                .foregroundColor(.appText)
        }
    }
}
