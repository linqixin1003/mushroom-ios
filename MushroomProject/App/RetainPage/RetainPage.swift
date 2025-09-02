import SwiftUI
import StoreKit
import Combine

struct RetainActionModel {
    let onCloseClick = PassthroughSubject<Void, Never>()
    let onRestoreClick = PassthroughSubject<Void, Never>()
    let onPurchaseClick = PassthroughSubject<String, Never>()
}

struct RetainPage: View {
    let selectedSku: String
    @ObservedObject var purchaseManager = LocalPurchaseManager.shared
    let actionModel: RetainActionModel
    
    var body: some View {
        ZStack(alignment: .top) {
            // 黑色背景
            Color.black.ignoresSafeArea()
            // 顶部背景图
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Image("retain_bg")
                        .resizable()
                        .frame(width: geo.size.width, height: geo.size.width * 256 / 375)
                        .clipped()
                    Spacer()
                }
                .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // 顶部栏
                HStack {
                    Button(action: {
                        self.actionModel.onRestoreClick.send()
                    }) {
                        Text(Language.retain_restore)
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .regular))
                    }
                    .padding(.leading, 16)
                    Spacer()
                    Button(action: {
                        self.actionModel.onCloseClick.send()
                    }) {
                        Image("convertpage_close")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, SafeTop + 8)
                .padding(.bottom, 8)
                
                // 标题
                Text(Language.retain_title)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 62)
                    .padding(.bottom, 12)
                
                Spacer()
                
                // 内容区
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 32)
                    // 时间线
                    Spacer()
                    HStack(alignment: .top, spacing: 0) {
                        VStack(spacing: 0) {
                            TimelineIcon(name: "icon_retain1")
                            TimelineLine(height: 56, startColor: Color(red: 128/255, green: 128/255, blue: 128/255), endColor: Color(red: 128/255, green: 128/255, blue: 128/255))
                            TimelineIcon(name: "icon_retain2")
                            TimelineLine(height: 56, startColor: Color(red: 106/255, green: 106/255, blue: 106/255), endColor: Color(red: 86/255, green: 86/255, blue: 86/255))
                            TimelineIcon(name: "icon_retain3")
                            TimelineLine(height: 56, startColor: Color(red: 80/255, green: 80/255, blue: 80/255), endColor: Color(red: 0, green: 0, blue: 0))
                        }
                        .padding(.leading, 32)
                        VStack(alignment: .leading, spacing: 0) {
                            TimelineText(title: Language.retain_timeline_today, desc: Language.retain_timeline_today_desc)
                            Spacer().frame(height: 34)
                            TimelineText(title: Language.retain_timeline_day1_6, desc: Language.retain_timeline_day1_6_desc)
                            Spacer().frame(height: 40)
                            TimelineText(title: Language.retain_timeline_day7, desc: Language.retain_timeline_day7_desc)
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 24)
                    }
                    .padding(.bottom, 32)
                    Spacer()
                    
                    // 试用说明
                    Text(Language.retain_try_free)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 2)
                        .frame(maxWidth: .infinity, alignment: .center)
                    if selectedPrice != "?" {
                        // 突出显示价格的组合文本
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(Language.retain_price_then)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            Text(selectedPrice)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0, green: 0.86, blue: 0.59))
                            Text(Language.retain_price_year_cancel)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 16)
                    } else {
                        Text(Language.retain_loading_price)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 16)
                    }
                    
                    // 绿色按钮
                    Button(action: {
                        // Only allow purchase when valid price is retrieved
                        guard selectedPrice != "?" else {
                            debugPrint("[RetainPage] ⚠️ \(Language.debug_price_not_retrieved)")
                            return
                        }
                        self.actionModel.onPurchaseClick.send(selectedSku)
                    }) {
                        Text(Language.retain_start_trial)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: 0xFF7E4E),
                                    Color(hex: 0xFF5959)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .cornerRadius(28)
                            .opacity(selectedPrice != "?" ? 1.0 : 0.6) // Reduce opacity when price not retrieved
                    }
                    .disabled(selectedPrice == "?") // Disable button when price not retrieved
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var selectedPrice: String {
        purchaseManager.products.first(where: { $0.id == selectedSku })?.displayPrice ?? "?"
    }
    
    // 时间线icon
    private struct TimelineIcon: View {
        let name: String
        var body: some View {
            Image(name)
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
    // 时间线竖线
    private struct TimelineLine: View {
        let height: CGFloat
        let startColor: Color
        let endColor: Color
        
        var body: some View {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [startColor, endColor]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 10, height: height)
                .padding(.leading, 0)
        }
    }
    // 时间线文本
    private struct TimelineText: View {
        let title: String
        let desc: String
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
            }
        }
    }
}

struct RetainPage_Previews: PreviewProvider {
    static var previews: some View {
        RetainPage(
            selectedSku: LocalPurchaseManager.ProductID.yearlyWithTrial,
            actionModel: RetainActionModel()
        )
        .previewDevice("iPhone 14 Pro")
    }
} 
