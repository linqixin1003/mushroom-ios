//
//  ConvertPage.swift
//  RockProject
//
//  Created by conalin on 2025/5/26.
//

import SwiftUI
import Combine
import StoreKit

struct ConvertActionModel {
    let onCloseClick = PassthroughSubject<Void, Never>()
    let onPurchaseClick = PassthroughSubject<String, Never>()
    let onSkuChanged = PassthroughSubject<String, Never>()
    let onTermsOfUseClick = PassthroughSubject<Void, Never>()
    let onPrivacyPolicyClick = PassthroughSubject<Void, Never>()
    let onRestoreClick = PassthroughSubject<Void, Never>()
}

struct ConvertPage: View {
    
    @ObservedObject var purchaseManager = LocalPurchaseManager.shared
    let actionModel: ConvertActionModel
    
    @State private var selectedSku: String = LocalPurchaseManager.ProductID.yearlyWithTrial
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 黑色45
            Color.black.ignoresSafeArea()
            // 顶部背景图
            // 使用GeometryReader实现自适应布局，根据屏幕尺寸调整背景图片大小
            GeometryReader { geo in
                ScrollView {
                    ZStack{
                        VStack(spacing: 0) {
                            // 转换页面顶部背景图片，宽高比保持256:375
                            Image("convertpage_bg")
                                .resizable()
                                .frame(width: geo.size.width, height: geo.size.width * 256 / 375)
                                .clipped()
                            Spacer()
                        }
                        
                        VStack {
                            Spacer().frame(height: SafeTop + 120.rpx)
                            
                            // 标题
                            Text(Language.convert_title)
                                .font(.system(size: 36.rpx, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.top, 36.rpx)
                            
                            GeometryReader { geo2 in
                                VStack {
                                    // 功能点
                                    VStack(alignment: .leading, spacing: 10.rpx) {
                                        
                                        FeatureRow(text: Language.convert_feature_1)
                                            .frame(height: geo2.size.height*0.13)
                                        FeatureRow(text: Language.convert_feature_2)
                                            .frame(height: geo2.size.height*0.13)
                                        FeatureRow(text: Language.convert_feature_3)
                                            .frame(height: geo2.size.height*0.13)
                                        FeatureRow(text: Language.convert_feature_4)
                                            .frame(height: geo2.size.height*0.13)
                                        FeatureRow(text: Language.convert_feature_5)
                                            .frame(height: geo2.size.height*0.13)
                                        Spacer()
                                    }
                                }.frame(width: geo2.size.width, height: geo2.size.height, alignment: .center)
                            }
                            .frame(height: .infinity)
                        
                            // 试用说明
                            if self.selectedSku == LocalPurchaseManager.ProductID.yearlyWithTrial {
                                VStack {
                                    if yearlyPrice != "?" {
                                        // 使用HStack替代'+'操作符组合文本，修复buildExpression编译错误
                                        let trialTextFormat = Language.convert_free_trial_yearly
                                        let components = trialTextFormat.components(separatedBy: "%@")
                                        
                                        if components.count >= 2 {
                                            HStack(spacing: 0) {
                                                Text(components[0])
                                                    .font(.system(size: 18.rpx, weight: .regular))
                                                    .foregroundColor(.white)
                                                Text(self.yearlyPrice)
                                                    .font(.system(size: 24.rpx, weight: .bold))
                                                    .foregroundColor(.white)
                                                Text(components[1])
                                                    .font(.system(size: 18.rpx, weight: .regular))
                                                    .foregroundColor(.white)
                                            }
                                        } else {
                                            Text(String(format: trialTextFormat, self.yearlyPrice))
                                                .font(.system(size: 18.rpx, weight: .regular))
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        Text(Language.convert_free_trial_loading)
                                            .foregroundColor(.white)
                                            .font(.system(size: 14.rpx))
                                    }

                                }
                                .padding(.top, 16.rpx)
                                .padding(.bottom,3.rpx)
                                
                                Text(Language.convert_cancel_notice)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16.rpx))
                                    .padding(.horizontal, 24.rpx)
                            }

                            // 试用按钮
                            Button(action: {
                                // Only allow purchase when valid price is retrieved
                                guard yearlyPrice != "?" else {
                                    debugPrint("[ConvertPage] ⚠️ \(Language.debug_price_not_retrieved)")
                                    return
                                }
                                self.actionModel.onPurchaseClick.send(self.selectedSku)
                            }) {
                                Text(Language.convert_continue)
                                    .font(.system(size: 24.rpx, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: 0xFF7E4E),
                                            Color(hex: 0xFF5959)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .cornerRadius(28.rpx)
                                    .opacity(yearlyPrice != "?" ? 1.0 : 0.6) // Reduce opacity when price not retrieved
                            }
                            .disabled(yearlyPrice == "?") // Disable button when price not retrieved
                            .padding(.horizontal, 24.rpx)
                            
                            // 底部说明
                            VStack(alignment: .leading, spacing: 0) {
                                Text(Language.convert_cancel_anytime)
                                    .font(.system(size: 15.rpx, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 10.rpx)
                                
                                RichTextView(
                                    paymentTerms: Language.convert_payment_terms,
                                    termsOfUse: Language.convert_terms_of_use,
                                    andText: Language.convert_and,
                                    privacyPolicy: Language.convert_privacy_policy,
                                    onTermsClick: { self.actionModel.onTermsOfUseClick.send() },
                                    onPrivacyClick: { self.actionModel.onPrivacyPolicyClick.send() }
                                )
                            }
                            .multilineTextAlignment(.leading)
                            .padding(.top, 10.rpx)
                            .padding(.horizontal, 18.rpx)
                            .padding(.bottom, 20.rpx)
                        }
                    }.frame(minHeight: UIScreen.main.bounds.height + 56.rpx).ignoresSafeArea()
                }
            }
            
            
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
//            // 顶部关闭按钮
//            Button(action: {
//                self.actionModel.onCloseClick.send()
//            }) {
//                Image("convertpage_close")
//                    .resizable()
//                    .frame(width: 28.rpx, height: 28.rpx)
//                    .padding(.top, 12.rpx)
//                    .padding(.trailing, 12.rpx)
//            }
//            .padding(.top, SafeTop)
        }
    }
    
    private var yearlyPrice: String {
        self.purchaseManager.products.first(where: { $0.id == LocalPurchaseManager.ProductID.yearlyWithTrial })?.displayPrice ?? "?"
    }
    
    private var monthlyPrice: String {
        self.purchaseManager.products.first(where: { $0.id == LocalPurchaseManager.ProductID.monthly })?.displayPrice ?? "?"
    }
}

// 功能点行
struct FeatureRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .center, spacing: 8.rpx) {
            Image("icon_right")
                .foregroundColor(Color.green)
                .font(.system(size: 18.rpx))
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 15.rpx))
        }
    }
}

// 富文本视图，支持精确点击
struct RichTextView: View {
    let paymentTerms: String
    let termsOfUse: String
    let andText: String
    let privacyPolicy: String
    let onTermsClick: () -> Void
    let onPrivacyClick: () -> Void
    
    var body: some View {
        Text(attributedString)
            .font(.system(size: 11.rpx))
            .fixedSize(horizontal: false, vertical: true)
            .environment(\.openURL, OpenURLAction { url in
                if url.absoluteString == "terms://click" {
                    onTermsClick()
                    return .handled
                } else if url.absoluteString == "privacy://click" {
                    onPrivacyClick()
                    return .handled
                }
                return .systemAction
            })
    }
    
    private var attributedString: AttributedString {
        var result = AttributedString()
        
        // 付款条款文本
        var paymentText = AttributedString(paymentTerms + " ")
        paymentText.foregroundColor = .white
        result += paymentText
        
        // 使用条款链接
        var termsText = AttributedString(termsOfUse)
        termsText.foregroundColor = .primary
        termsText.underlineStyle = .single
        termsText.link = URL(string: "terms://click")
        result += termsText
        
        // 连接词
        var andTextAttr = AttributedString(" " + andText + " ")
        andTextAttr.foregroundColor = .white
        result += andTextAttr
        
        // 隐私政策链接
        var privacyText = AttributedString(privacyPolicy)
        privacyText.foregroundColor = .primary
        privacyText.underlineStyle = .single
        privacyText.link = URL(string: "privacy://click")
        result += privacyText
        
        return result
    }
}

struct RockAiSnapSubscribePage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConvertPage(actionModel: ConvertActionModel())
        }
    }
}

