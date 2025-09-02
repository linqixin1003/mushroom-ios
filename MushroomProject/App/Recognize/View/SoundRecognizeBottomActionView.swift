import SwiftUI

struct SoundRecognizeBottomActionView : View {
    let isRecording:Bool
    let onRecord: (() -> Void)
    
    var body: some View {
        HStack(alignment: .center) {
            Button {
                self.onRecord()
            } label: {
                Image(isRecording ? "icon_sound_recording" : "icon_sound_normal")
                    .frame(width: 80.rpx, height: 80.rpx)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
