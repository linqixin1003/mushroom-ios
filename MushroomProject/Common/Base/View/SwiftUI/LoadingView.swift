
import SwiftUI

struct LoadingLayoutView<Content>: View where Content: View {
    @Binding var status: UILoadingState
    private let ignoreNavigationHeight: Bool
    private var onRetryClick: () -> Void
    private let loadingContent: (() -> AnyView)?
    private let content: Content

    public init(
        status: Binding<UILoadingState>,
        ignoreNavigationHeight: Bool = false,
        onRetryClick: @escaping () -> Void,
        loadingContent: (() -> AnyView)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._status = status
        self.ignoreNavigationHeight = ignoreNavigationHeight
        self.onRetryClick = onRetryClick
        self.loadingContent = loadingContent
        self.content = content()
    }

    var body: some View {
        ZStack {
            switch status {
            case .idle, .loading:
                if let loadingContent = loadingContent {
                    loadingContent()
                } else {
                    VStack {
                        GLCircularProgressIndicator()
                            .frame(width: 50.rpx, height: 50.rpx)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
            case .success:
                content
            case .error:
                LoadingErrorContentView(ignoreNavigationHeight: ignoreNavigationHeight, onRetryClick: onRetryClick)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct LoadingContentView: View {
    var body: some View {
        ProgressView()
            
    }
}

struct LoadingErrorContentView: View {
    var ignoreNavigationHeight: Bool = false
    let onRetryClick: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if ignoreNavigationHeight {
                Spacer()
                    .frame(height: NavBarHeight)
            }
            
            Spacer()
                .frame(height: 100.rpx)
            
            Image("icon_retry_120")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120.rpx, height: 120.rpx)
            
            Spacer()
                .frame(height: 24.rpx)
            
            Text(Language.text_common_error_try_again)
                .font(.bold(20.rpx))
                .foregroundColor(Color(hex: 0x000000))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32.rpx)
            
//            Spacer()
//                .frame(height: 8.rpx)
//            
//            Text(Language.TEXT_PLEASECHECK)
//                .textStyle(.footnoteRegular)
//                .foregroundColor(.tE2)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 32.rpx)
            
            Spacer().frame(height: 32.rpx)
            
            HStack {
                Text(Language.text_try_again)
                    .font(.medium(20.rpx))
                    .foregroundColor(Color.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 18.rpx)
            .frame(height: 58.rpx)
            .onTapGesture {
                onRetryClick()
            }
            
            Spacer()
        }
    }
}

public struct GLCircularProgressIndicator: View {
    
    public var lineWidth: CGFloat
    public var animationDuration: Double
    public var foregroundColor: Color
    
    @State private var rotation: Double = 0
    
    public init(lineWidth: CGFloat = 5.rpx, animationDuration: Double = 1.0, foregroundColor: Color = Color(red: 0.12, green: 0.53, blue: 0.90)) {
        self.lineWidth = lineWidth
        self.animationDuration = animationDuration
        self.foregroundColor = foregroundColor
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(
                    AngularGradient(
                        colors: [foregroundColor.opacity(0), foregroundColor.opacity(1)],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    // 使用 Timer 来创建连续的旋转动画
                    withAnimation(
                        Animation
                            .linear(duration: animationDuration)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotation = 360
                    }
                }
                .onDisappear {
                    // 在视图消失时重置旋转角度
                    rotation = 0
                }
        }
    }
}
