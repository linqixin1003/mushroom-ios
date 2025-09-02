import SwiftUI
import Kingfisher

struct HomeDailyStoneSectionView: View {
    let stone: SimpleMushroom
    let collected: Bool
    
    let onCollectClick: () -> Void
    let onShareClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6.rpx) {
            Text(Language.home_your_daily_stone)
                .font(.system(size: 16.rpx, weight: .semibold))
                .lineSpacing(4.rpx)
                .foregroundColor(Color(hex: 0x131C1B))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HomeDailyStoneCardView(
                stone: self.stone,
                collected: self.collected,
                onCollectClick: self.onCollectClick,
                onShareClick: self.onShareClick
            )
        }
    }
}

private struct HomeDailyStoneCardView: View {
    let stone: SimpleMushroom
    let collected: Bool
    
    let onCollectClick: () -> Void
    let onShareClick: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            KFImage
                .url(URL(string: self.stone.photoUrl ?? ""))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 165.rpx)
                .clipped()
            
            HStack(spacing: 16.rpx) {
                Text(self.stone.name)
                    .font(.system(size: 14.rpx, weight: .semibold))
                    .lineSpacing(4.rpx)
                    .foregroundColor(Color(hex: 0xFFFFFF))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(self.collected ? "icon_collected_24" : "icon_uncollected_24") // TODO: 111 icon
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24.rpx, height: 24.rpx)
                    .onTapGesture {
                        self.onCollectClick()
                    }
                
                Image("icon_share_24")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24.rpx, height: 24.rpx)
                    .onTapGesture {
                        self.onShareClick()
                    }
            }
            .padding(.horizontal, 16.rpx)
            .frame(maxWidth: .infinity)
            .frame(height: 42.rpx)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color(hex:0x000000).opacity(0), Color(hex:0x000000).opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            ))
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(10.rpx)
    }
}

