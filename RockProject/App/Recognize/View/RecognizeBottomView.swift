import SwiftUI

struct RecognizeBottomView : View {
    var onAlbumClick: (() -> Void)?
    var onCaptureClick: (() -> Void)?
    var onTipsClick: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 30.rpx) {
            RecognizeBottomActionView(
                albumAction: { onAlbumClick?() },
                captureAction: { onCaptureClick?() },
                tipsAction: { onTipsClick?() }
            )
        }
        .padding(.top, 26.rpx)
        .padding(.bottom, 38.rpx)
        .background(Color.white)
    }
}
