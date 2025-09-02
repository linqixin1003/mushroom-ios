import SwiftUI
import Combine
struct ValuationResultActionModel {
    let navBackClick = PassthroughSubject<Void, Never>()
    let viewFullImage = PassthroughSubject<Void, Never>()
}

struct ValuationResultPage: View {
    let result: ValuationResponse
    let capturedImage: UIImage?
    let actionModel: ValuationResultActionModel

    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.valuationResultOpen, closeEventName: EventName.valuationResultClose)
    @State private var hasSatisfied: Bool = false

    var body: some View {
        AppPage(
            title: "",
            leftButtonConfig: .init(imageName: "icon_back_24", onClick: {
                self.actionModel.navBackClick.send()
            }),
            rightButtonConfig: nil
        ) {
            VStack(spacing: 0) {
                // 添加一个ZStack来确保图片不会覆盖导航栏
                ZStack(alignment: .center) {
                    if let capturedImage {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 240.rpx)
                            .clipped()
                    }
                }.onTapGesture {
                    // 点击：回传 index 与 urls（父级可用 imageUrls[index] 获取当前 URL）
                    FireBaseEvent.send(
                        eventName: EventName.valuationMainImageClick
                    )
                    self.actionModel.viewFullImage.send()
                }
                .zIndex(0) // 确保图片在导航栏下方

                VStack(alignment: .leading, spacing: 12.rpx) {

                    // 详细信息
                    Group {
                        keyValueRow(key: Language.mushroom_estimated_value, value: formatPrice(result.estimatedPrice))
                        keyValueRow(key: Language.possible_price_range, value: formatRange(result.minPrice, result.maxPrice))
                    }
                    .padding(.horizontal, 4.rpx)

                    // 理由（占据剩余空间，内部可滚动）
                    ZStack {
                        RoundedRectangle(cornerRadius: 12.rpx)
                            .fill(Color(hex: 0xFFFEF8F1))
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10.rpx) {
                                Text(Language.note)
                                    .font(.system(size: 16.rpx, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(result.reasoning)
                                    .font(.system(size: 14.rpx))
                                    .foregroundColor(.primary)
                                    .lineSpacing(6.rpx)
                                    .padding(.top, 2.rpx)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(16.rpx)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(16.rpx)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                // 满意度调查
                if !hasSatisfied {
                    Spacer().frame(height: 16.rpx)
                    Text(Language.are_you_satisfied_with_the_result)
                        .font(.system(size: 16.rpx, weight: .semibold))
                        .foregroundColor(.appText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 16.rpx)
                    Spacer().frame(height: 16.rpx)
                    HStack(spacing: 16.rpx) {
                        Button {
                            ToastUtil.showToast(Language.thanks_for_your_feedback)
                            hasSatisfied = true
                            FireBaseEvent.send(eventName: EventName.valuationResultYesClick, params: [:])
                        } label: {
                            Text(Language.text_yes)
                                .font(.system(size: 16.rpx))
                                .foregroundColor(.appText)
                                .frame(width: 100.rpx, height: 40.rpx)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40.rpx)
                                        .stroke(Color.appTextLight, lineWidth: 1)
                                )
                        }

                        Button {
                            ToastUtil.showToast(Language.thanks_for_your_feedback)
                            hasSatisfied = true
                            FireBaseEvent.send(eventName: EventName.valuationResultNoClick, params: [:])
                        } label: {
                            Text(Language.text_no)
                                .font(.system(size: 16.rpx))
                                .foregroundColor(.appText)
                                .frame(width: 100.rpx, height: 40.rpx)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40.rpx)
                                        .stroke(Color.appTextLight, lineWidth: 1)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8.rpx)
                    .padding(.bottom, 8.rpx)
                }

                Spacer().frame(height: 40.rpx)
            }
        }
    }

    private func keyValueRow(key: String, value: String) -> some View {
        HStack {
            Text(key)
                .font(.system(size: 16.rpx, weight: .medium))
                .foregroundColor(.appTextLight)
            Spacer()
            Text(value)
                .font(.system(size: 16.rpx))
                .foregroundColor(.appText)
        }
        .padding(6.rpx)
        .background(Color.white)
        .cornerRadius(10.rpx)
    }

    private func formatPrice(_ price: Double) -> String {
       return "$" + String(format: "%.2f", price)
    }

    private func formatRange(_ min: Double, _ max: Double) -> String {
        return "$\(String(min)) - $\(String(max))"
    }
}
