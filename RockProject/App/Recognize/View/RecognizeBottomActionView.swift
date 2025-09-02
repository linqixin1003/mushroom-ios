import SwiftUI

struct RecognizeBottomActionView : View {

    let albumAction: () -> Void
    let captureAction: () -> Void
    let tipsAction: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Button {
                    self.albumAction()
                } label: {
                    VStack {
                        Image("icon_camera_album_36")
                        Text(Language.text_photo)
                            .font(.regular(14.rpx))
                            .lineSpacing(4.rpx)
                            .foregroundColor(Color(hex: 0x7F7F7F))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Button {
                self.captureAction()
            } label: {
                Image("icon_camera_capture_80")
                    .frame(width: 80.rpx, height: 80.rpx)
            }

            
            HStack {
                Button {
                    self.tipsAction()
                } label: {
                    VStack {
                        Image("icon_camera_help_32")
                        Text(Language.text_tips)
                            .font(.regular(14.rpx))
                            .lineSpacing(4.rpx)
                            .foregroundColor(Color(hex: 0x7F7F7F))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
        }
        .frame(maxWidth: .infinity)
    }
}

struct RecognizeBottomView_Previews: PreviewProvider {
    static var previews: some View {
        RecognizeBottomActionView(albumAction: {}, captureAction: {}, tipsAction: {})
    }
}

