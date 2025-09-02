import SwiftUI
import Kingfisher
import UIKit

struct CompareImagePage: View {
    let referenceImageUrl: String
    let capturedImage: UIImage?
    let onCloseClick: () -> Void
    
    var body: some View {
        AppPage(
            title: Language.text_photo,
            leftButtonConfig: .init(imageName: "icon_back_24", onClick: {
                self.onCloseClick()
            })
        ) {
            VStack(spacing: 0) {
                // 参考图片 (顶部)
                KFImage
                    .url(URL(string: referenceImageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280.rpx)
                    .clipped()
                
                Spacer()
                    .frame(height: 12.rpx)
                
                // 用户拍摄的图片 (底部，占据剩余空间)
                if let capturedImage = capturedImage {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .frame(maxHeight: .infinity)
                } else {
                    // 如果没有拍摄图片，显示占位符
                    Image("image_placeholder_mid")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }
}

#Preview {
    CompareImagePage(
        referenceImageUrl: "https://example.com/image.jpg",
        capturedImage: nil,
        onCloseClick: {}
    )
}
