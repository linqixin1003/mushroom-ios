import UIKit
import SwiftUI
import AVFoundation
import Photos
import Combine

class IdentifyResultViewController: BaseHostingViewController<IdentifyResultPage> {
    
    let viewModel: RecognizeViewModel
    let actionModel = IdentifyLoadingActionModel()
    
    init(viewModel: RecognizeViewModel) {
        self.viewModel = viewModel
        super.init(rootView: IdentifyResultPage(viewModel: self.viewModel))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

struct IdentifyLoadingActionModel {
    let onCloseClick = PassthroughSubject<Void, Never>()
    let onRetakeClick = PassthroughSubject<Void, Never>()
}

// MARK: - IdentifyResultPage
struct IdentifyResultPage: View {
    @ObservedObject var viewModel: RecognizeViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // 顶部图片
                Image(uiImage: self.viewModel.currentImage ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 240.rpx)
                    .clipShape(RoundedCorner(radius: 16.rpx, corners: [.topLeft, .topRight]))
                
                // 结果内容
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                        .frame(height: 30.rpx)
                    
                    if let stone = viewModel.identifyResult?.stone {
                        Text(stone.name)
                            .font(.regular(14.rpx))
                            .lineSpacing(2.rpx)
                            .foregroundColor(.appTextLight)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .padding(.horizontal, 20.rpx)
            }
            
            // TopNavBar
            HStack {
                Button {
                    self.viewModel.identifyState = .idle
                } label: {
                    Image("icon_camera_close_32")
                        .frame(width: 32.rpx, height: 32.rpx)
                }
                
                Spacer()
                
                Button {
                    self.viewModel.identifyState = .idle
                } label: {
                    Image("icon_camera_retake_32")
                        .frame(width: 32.rpx, height: 32.rpx)
                }
                .accessibilityLabel(Language.camera_retake)
            }
            .padding(.top, SafeTop)
            .padding(.horizontal, 16.rpx)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

// MARK: - RoundedCorner
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

