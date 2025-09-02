import SwiftUI
import Combine
struct AccountManangerAction{
    let backClick = PassthroughSubject<Void, Never>()
    let onDeleteClick = PassthroughSubject<Void, Never>()
}

struct AccountManagerScreen:View{
    let action:AccountManangerAction
    @State private var isPresented = false
    var body:some View{
        AppPage(
            title: "Manage Account",
            leftButtonConfig: .init(
                imageName: "icon_back_24",
                onClick: {
                    self.action.backClick.send()
                }
            ),
            rightButtonConfig: nil
        ) {
            VStack{
                Spacer()
                Text(Language.account_delete_warning)
                    .font(.system(size: 14.rpx))
                    .lineSpacing(6.rpx)
                    .foregroundColor(.appTextLight)
                   .padding(.horizontal, 30.rpx)
                Spacer()
                ZStack{
                    Button(action: {
                        FireBaseEvent.send(eventName: EventName.accountManagerDeleteClick)
                        isPresented = true
                    }) {
                        Text(Language.account_delete_information)
                            .font(.system(size: 18.rpx))
                           .foregroundColor(Color(hex:0xFFFC4A4A))
                           .frame(width: 340.rpx, height: 58.rpx)
                    }
                    .background(Color(hex:0xFFFC4A4A).opacity(0.1))
                    .cornerRadius(30.rpx)
                    .frame(width: 340.rpx, height: 58.rpx)
                    .alert(Language.account_warning, isPresented: $isPresented) {
                        // Cancel 按钮
                        Button(Language.account_cancel, role: .cancel) {
                            FireBaseEvent.send(eventName: EventName.accountManagerDeleteCancelClick)
                            isPresented = false
                        }
                        // Delete 按钮
                        Button(Language.account_delete, role: .destructive) {
                            self.action.onDeleteClick.send()
                        }
                    } message: {
                        Text(Language.account_delete_confirmation)
                            .font(.system(size: 14.rpx))
                            .foregroundColor(.appTextLight)
                    }
                }
                .frame(maxWidth:.infinity)	
                .frame(height: 88.rpx)
                .background(.white)
            }
            .frame(maxWidth:.infinity, maxHeight: .infinity)
        }
    }
}

