import Combine
import SwiftUI

struct SuggestionAction {
    var onBack = PassthroughSubject<Void, Never>()
    var onEmailInput = PassthroughSubject<String, Never>()
    var onDescriptionInput = PassthroughSubject<String, Never>()
    var onSend = PassthroughSubject<Void, Never>()
}

struct SuggestionScreen: View {
    let action: SuggestionAction
    @ObservedObject var viewModel: SuggestionViewModel
    @State var bImage:UIImage? = nil
    var body: some View {
        AppPage(
            title: "Suggestion",
            leftButtonConfig: .init(
                imageName: "icon_back_24",
                onClick: {
                    self.action.onBack.send()
                }
            ),
            rightButtonConfig: nil
        ) {
            ScrollView {
                VStack(spacing: 18.rpx) {
                    VStack(spacing: 10.rpx) {
                        SuggestionItem(
                            title: "Your Email",
                            hint: "Email Address"
                        ) { text in
                            self.action.onEmailInput.send(text)
                        }

                        SuggestionItem(
                            title: "Description",
                            hint: "Describe your suggestions here"
                        ) { text in
                            self.action.onDescriptionInput.send(text)
                        }

                        VStack(spacing: 13.rpx) {
                            Text(
                                "Add Images (\(viewModel.images.count)/3)"
                            )
                            .font(.system(size: 16.rpx, weight: .semibold))
                            .foregroundColor(.appText)
                            .frame(height: 60.rpx)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 13.rpx) {
                                ForEach(0..<3) { index in
                                    AddImageView(
                                        uiImage: viewModel.getImage(index)
                                    ){
                                        FireBaseEvent.send(eventName: EventName.suggestionImageDeleteClick, params:[EventParam.index: String(index)])
                                        self.viewModel.images.remove(at: index)
                                    }
                                    .frame(width: 100.rpx, height: 100.rpx)
                                    .background(
                                        Color(
                                            red: 224 / 255,
                                            green: 230 / 255,
                                            blue: 229 / 255,
                                            opacity: 0.7
                                        )
                                    )
                                    .cornerRadius(6.rpx)
                                    .onTapGesture {
                                        FireBaseEvent.send(eventName: EventName.suggestionImageClick, params:[EventParam.index: String(index)])
                                        self.viewModel.imageSelect = true                                 }
                        
                                }
                            }
                        }
                    }
                    .padding(
                        EdgeInsets(
                            top: 19.rpx,
                            leading: 15.rpx,
                            bottom: 19.rpx,
                            trailing: 15.rpx
                        )
                    )
                    .background(Color(.systemBackground))
                    .cornerRadius(6.rpx)
                    .padding(
                        EdgeInsets(
                            top: 12.rpx,
                            leading: 10.rpx,
                            bottom: 12.rpx,
                            trailing: 10.rpx
                        )
                    )

                    Button(action: {
                        if viewModel.isSendEnable {
                            self.action.onSend.send()
                        }
                    }) {
                        Text(Language.suggestion_send)
                            .font(.system(size: 20.rpx, weight: .semibold))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58.rpx)
                    }
                    .background(
                        viewModel.isSendEnable
                            ? Color.primary : Color.gray
                    )
                    .cornerRadius(30.rpx)
                    .padding(
                        EdgeInsets(top: 0, leading: 18.rpx, bottom: 0, trailing: 18.rpx)
                    )
                }
                .sheet(isPresented: $viewModel.imageSelect) {
                    ImagePicker(selectedImage: $bImage, didSelectImage: { image in
                        self.viewModel.images.append(image)
                        
                    })
                }
            }
        }
    }
}


struct AddImageView: View {
    var uiImage: UIImage?
    var onDelete: () -> Void
    var body: some View {
        ZStack {
            if uiImage == nil {
                ZStack{
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 39.rpx, height: 39.rpx)
                        .foregroundColor(.white)
                }
                .frame(width: 100.rpx, height: 100.rpx)
                .background(Color(hex:0xFFE0E6E5).opacity(0.7))
            } else {
                Image(uiImage:self.uiImage!)
                    .resizable()
                    .frame(width: 100.rpx, height: 100.rpx)
                    .scaledToFit()
            }

            if uiImage != nil {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 18.rpx, height: 18.rpx)
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6.rpx))
    }
}

struct SuggestionItem: View {
    var title: String
    var hint: String
    var onValueChange: (String) -> Void

    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4.rpx) {
                Text(Language.suggestion_required_field)
                    .foregroundColor(.red)
                    .font(.system(size: 16.rpx))
                Text(title)
                    .font(.system(size: 16.rpx, weight: .semibold))
                    .foregroundColor(.appText)
            }
            .frame(height: 36.rpx)

            TextField(
                "",
                text: $text,
                onEditingChanged: { _ in },
                onCommit: {
                    onValueChange(text)
                }
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .background(
                Color(
                    red: 224 / 255,
                    green: 230 / 255,
                    blue: 229 / 255,
                    opacity: 0.8
                )
            )
            .cornerRadius(6.rpx)
            .frame(height: 44.rpx)
            .onChange(of: text) { newValue in
                onValueChange(newValue)
            }
            .overlay(	
                Group {
                    if text.isEmpty {
                        Text(hint)
                            .foregroundColor(Color.secondary.opacity(0.8))
                            .padding(.leading, 8.rpx)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            )
        }
    }
}
