import SwiftUI
import Combine
import Kingfisher

struct MoreImagePage: View {
    
    let imageUrls: [String]
    let onCloseClick: () -> Void
    let onImageClick: (Int) -> Void
    
    private var uniqueImageUrls: [String] {
        var seen = Set<String>()
        return imageUrls.filter { url in
            if seen.contains(url) {
                return false
            } else {
                seen.insert(url)
                return true
            }
        }
    }
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.moreImageOpen, closeEventName: EventName.moreImageClose)
    var body: some View {
        AppPage(
            title: Language.more_images,
            leftButtonConfig: .init(imageName: "icon_back_24", onClick: {
                FireBaseEvent.send(eventName: EventName.moreImageCloseClick)
                self.onCloseClick()
            }),
            rightButtonConfig: nil
        ) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12.rpx) {
                    ForEach(self.uniqueImageUrls.indices, id: \.self) { index in
                        MoreImageItem(imageUrl: self.imageUrls[index]).onTapGesture {
                            FireBaseEvent.send(eventName: EventName.moreImageItemClick, params: [EventParam.index: String(index)])
                            self.onImageClick(index)
                        }
                    }
                }
                .padding(.horizontal, 20.rpx)
                .padding(.top, 20.rpx)
            }
            
        }
    }
}

struct MoreImageItem: View {
    let imageUrl: String
    
    var body: some View {
        KFImage
            .url(URL(string: self.imageUrl))
            .placeholder {
                ZStack {
                    Color.gray.opacity(0.1)
                    ProgressView()
                }
            }
            .onFailure { error in
                print("Image loading failed: \(error.localizedDescription)")
            }
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(6.rpx)
            .background(Color.gray.opacity(0.1))
    }
}
