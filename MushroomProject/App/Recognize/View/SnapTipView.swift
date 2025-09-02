import SwiftUI

struct SnapTipView : View {
    let onCloseClick: () -> Void
    let onOKClick: () -> Void
    
    var body: some View {
        VStack {
            Button {
                onCloseClick()
            } label: {
                Image("icon_camera_close_32")
                    .frame(width: 32.rpx, height: 32.rpx)
            }
            .padding(.top, SafeTop)
            .padding(.leading, 16.rpx)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                VStack(alignment: .center, spacing: 8.rpx){
                    Text(Language.snap_tip_photography_tips)
                    .font(.regular(24.rpx))
                    .foregroundColor(.white)
                
                    SnapTipsContentView()
                    .padding(.horizontal, 42.rpx)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button {
                onOKClick()
            } label: {
                Text(Language.text_ok)
                    .font(.regular(20.rpx))
                    .foregroundColor(.white)
                    .frame(width: 240.rpx, height: 48.rpx)
                    .background(Color.primary)
                    .clipShape(Capsule())
            }
            .padding(.bottom, SafeBottom + 8.rpx)
            .frame(maxWidth: .infinity)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }
}

struct SnapTipsContentView: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 8.rpx) {
            Image("img_snaptip_01")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 166.rpx)
                .overlay {
                    Image("icon_snaptip_yes_36")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(.bottom, 8.rpx)
                        .padding(.trailing, 8.rpx)
                }
            Text(Language.snap_tip_keep_mushroom_centered)
                .font(.regular(14.rpx))
                .foregroundColor(.white)
                .lineSpacing(4.rpx)

            HStack(alignment: .center, spacing: 8.rpx) {
                SnapTipSmallItemView(
                    image: "img_snaptip_02", text: Language.snap_tip_too_far
                )
                .frame(maxWidth: .infinity)
                
                SnapTipSmallItemView(
                    image: "img_snaptip_03", text: Language.snap_tip_too_close
                )
                .frame(maxWidth: .infinity)
            }
            
            HStack(alignment: .center, spacing: 8.rpx) {
                SnapTipSmallItemView(
                    image: "img_snaptip_04", text: Language.snap_tip_blurry
                )
                .frame(maxWidth: .infinity)
                
                SnapTipSmallItemView(
                    image: "img_snaptip_05", text: Language.snap_tip_multiple_species
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct SnapTipSmallItemView: View {
    
    let image: String
    let text: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 3.rpx) {
            Image(self.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 166.rpx)
                .overlay {
                    Image("icon_snaptip_no_24")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(.bottom, 5.rpx)
                        .padding(.trailing, 5.rpx)
                }
            Text(self.text)
                .font(.regular(14.rpx))
                .foregroundColor(.white)
                .lineSpacing(4.rpx)
        }		
    }
}
