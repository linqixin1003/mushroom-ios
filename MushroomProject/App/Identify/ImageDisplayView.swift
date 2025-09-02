import SwiftUI
import Kingfisher
import UIKit

struct ImageDisplayView: View {
    let imageUrl: String
    let index: Int
    let imageUrls: [String]
    let capturedImage: UIImage?
    let stone: Mushroom
    let actionModel: IdentifyResultActionModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 背景大图：当前页 URL
            KFImage
                .url(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, minHeight: 280.rpx, maxHeight: 280.rpx)
                .clipped()
            
            // 左下角小图：拍照图片（若存在）
            HStack {
                if let capturedImage {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120.rpx, height: 80.rpx)
                        .clipShape(RoundedRectangle(cornerRadius: 8.rpx))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8.rpx)
                                .stroke(Color.white, lineWidth: 2.rpx)
                        )
                        .clipped()
                }
                Spacer()
            }
            .padding(10.rpx)
            .frame(height: 140.rpx)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 280.rpx)
    }
}

struct ImageTabView: View {
    let imageUrls: [String]
    let capturedImage: UIImage?
    let stone: Mushroom
    let actionModel: IdentifyResultActionModel
    let imageClick:(String, UIImage?) -> Void
    
    @State private var currentPage = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if imageUrls.isEmpty {
                // 兜底占位
                Color.black.opacity(0.05)
                    .frame(height: 280.rpx)
            } else {
                TabView(selection: $currentPage) {
                    ForEach(Array(imageUrls.enumerated()), id: \.offset) { idx, url in
                        ImageDisplayView(
                            imageUrl: url,
                            index: idx,
                            imageUrls: imageUrls,
                            capturedImage: capturedImage,
                            stone: stone,
                            actionModel: actionModel
                        )
                        .onTapGesture {
                            FireBaseEvent.send(
                                eventName: EventName.resultMainImageClick,
                                params: [EventParam.uid: self.stone.id, EventParam.index: String(idx)]
                            )
                            imageClick(url, capturedImage)
                        }
                        .tag(idx)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: currentPage) { newValue in
                    self.actionModel.onChangeResultClick.send(newValue)
                }
            }
            
            // 底部圆点指示器：覆盖在图片上，靠底对齐
            if imageUrls.count > 1 {
                HStack(spacing: 12.rpx) {
                    ForEach(0..<imageUrls.count, id: \.self) { idx in
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentPage = idx
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(currentPage == idx ? Color.accentColor : Color.white)
                                    .frame(width: 24.rpx, height: 24.rpx)
                                
                                Text("\(idx + 1)")
                                    .font(.system(size: 12.rpx, weight: .semibold))
                                    .foregroundColor(currentPage == idx ? .white : .black)
                            }
                        }
                    }
                }
                .padding(.bottom, 12.rpx)
            }
        }
        .frame(height: 280.rpx)
    }
}
