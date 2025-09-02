import SwiftUI
import Kingfisher

struct HomeNearStonesSectionView: View {
    let stones: [NearStone]
    let onStoneClick: (NearStone) -> Void
    let onViewAllClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6.rpx) {
            HStack {
                Text(Language.home_stones_near_you)
                    .font(.system(size: 16.rpx, weight: .semibold))
                    .lineSpacing(4.rpx)
                    .foregroundColor(Color(hex: 0x131C1B))
                
                Spacer()
                
//                HStack(spacing: 0) {
//                    Text(Language.text_view_all)
//                        .font(.system(size: 14.rpx, weight: .regular))
//                        .foregroundColor(Color(hex: 0x687473))
//                    
//                    Image("icon_arrow_right_16")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 16.rpx, height: 16.rpx)
//                }
//                .onTapGesture {
//                    self.onViewAllClick()
//                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, HomePageHorizontalPadding)
            
            HomeNearStonesView(
                stones: self.stones,
                onStoneClick: self.onStoneClick
            )
        }
    }
}

struct HomeNearStonesView: View {
    let stones: [NearStone]
    let onStoneClick: (NearStone) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8.rpx) {
                Spacer()
                    .frame(height: 8.rpx)
                
                ForEach(self.stones) { stone in
                    HomeNearStoneItem(stone: stone)
                        .onTapGesture {
                            self.onStoneClick(stone)
                        }
                }
                
                Spacer()
                    .frame(height: 8.rpx)
            }
        }
    }
}

struct HomeNearStoneItem: View {
    let stone: NearStone
    
    var body: some View {
        ZStack(alignment: .bottom) {
            KFImage
                .url(URL(string: self.stone.photoUrl))
                .placeholder {
                    Image("icon_nearby_placeholder")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.gray)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
            
            HStack(spacing: 16.rpx) {
                Text(self.stone.name)
                    .font(.system(size: 12.rpx, weight: .regular))
                    .foregroundColor(Color(hex: 0xFFFFFF))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 4.rpx)
            .frame(maxWidth: .infinity)
            .frame(height: 31.rpx)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color(hex:0x000000).opacity(0), Color(hex:0x000000).opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            ))
        }
        .frame(width: 106.rpx, height: 128.rpx)
        .cornerRadius(10.rpx)
    }
}
