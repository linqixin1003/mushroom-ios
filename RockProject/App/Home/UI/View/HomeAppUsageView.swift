import SwiftUI

struct HomeAppUsageView: View {
    var body: some View {
        HStack(spacing: 8.rpx) {
            VStack {
                Text(Language.home_app_usage_title)
                    .font(.system(size: 16.rpx, weight: .semibold))
                    .lineLimit(2)
                    .foregroundColor(Color(hex: 0x131C1B))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8.rpx)
                
                Spacer()
                
                Text(Language.home_app_usage_desc)
                    .font(.system(size: 12.rpx, weight: .regular))
                    .foregroundColor(Color(hex: 0x687473))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12.rpx)
            }
            
            Image("icon_home_app_usage_100")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100.rpx, height: 100.rpx)
        }
        .padding(14.rpx)
        .background(Color.white)
        .cornerRadius(12.rpx)
    }
}
