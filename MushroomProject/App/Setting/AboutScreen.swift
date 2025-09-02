import Combine
import SwiftUI

struct AboutAction {
    let backClick = PassthroughSubject<Void, Never>()
}

struct AboutScreen: View {
    let action: AboutAction
    var body: some View {
        AppPage(
            title: Language.about_app_name,
            leftButtonConfig: .init(
                imageName: "icon_back_24",
                onClick: {
                    self.action.backClick.send()
                }
            ),
            rightButtonConfig: nil
        ) {
            ZStack(alignment: .top) {
                Color(hex:0xF7EEE8)
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Spacer().frame(height: 41.rpx)
                    Image("icon_app")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 72.rpx, height: 72.rpx)
                        .clipShape(RoundedRectangle(cornerRadius: 10.rpx))
                    Spacer().frame(height: 6.rpx)
                    Text(Language.about_app_name)
                        .font(.system(size: 16.rpx))
                        .foregroundColor(.appText)
                    Spacer().frame(height: 4.rpx)
                    Text(String(format: Language.about_version, VersionHelper.getAppVersionName()))
                        .font(.system(size: 14.rpx))
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(maxWidth:.infinity)
                .frame(height: 203.rpx)
                
                
                VStack {
                    Spacer().frame(height: 185.rpx)
                    VStack {
                        Spacer().frame(height: 18.rpx)
                        Text(
                            "Don't know the name of stones? PictureMushroom helps you to identify unknownstones, discover nature with the mostsimple and interesting way.We also been working hard to providebetter user experience and optimize ourrecognition all the time! We would loveto have anyone who love stones join ourfamily.Let us start the journey encounteringthe most lovely stones from all over theworld."
                        )
                        .font(.system(size: 14.rpx))
                        .foregroundColor(.appText)
                        .lineSpacing(12.rpx)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 34.rpx)
                        
                        Spacer()
                        Divider()
                            .padding(.horizontal, 32.rpx)
                        Spacer().frame(height: 10.rpx)
                        HStack {
                            HStack {
                                Image("icon_email")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24.rpx, height: 24.rpx)
                                    .foregroundColor(.primary)
                                VStack(alignment: .leading) {
                                    Text("Gmail.com")//这个词条不要做多语言
                                        .font(.system(size: 12.rpx))
                                        .foregroundColor(.appText)
                                    Text(Config.EMAIL)
                                        .font(.system(size: 12.rpx))
                                        .foregroundColor(.primary)
                                }
                                .padding(.leading, 5.rpx)
                            }
                            .frame(height: 64.rpx)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 22.rpx)
                            .background(
                                RoundedRectangle(cornerRadius: 10.rpx)
                                    .stroke(Color(hex: 0xCECECE), lineWidth: 1)
                            )
                        }.padding(.horizontal, 22.rpx)
                        
                        Spacer()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16.rpx)
                            .foregroundColor(.white)
                    )
                    .padding(.top, 16.rpx)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
