import SwiftUI
import Combine

let HomePageHorizontalPadding = 18.rpx

struct HomePage: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var localizationManager = LocalizationManager.shared
    let actionModel: HomeActionModel
    
    @State private var showingAppInstrcuctionPage: Bool = false
    @State private var refreshKey: UUID = UUID()
    
    var body: some View {
        // 测试本地化
        let _ = Language.testLocalization()
        
        ZStack(alignment: .top) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: 0xDA8E46),
                    Color(hex: 0xAF9783).opacity(0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280.rpx)
            
            VStack(alignment: .center, spacing: 0) {
                
                HomeSearchBar()
                    .onTapGesture {
                        self.actionModel.onSearchClick.send()
                    }
                
                Spacer()
                    .frame(height: 20.rpx)
                
                if self.viewModel.showVipBanner {
                    HomeVipBanner()
                        .padding(.horizontal, HomePageHorizontalPadding)
                        .padding(.bottom, 8.rpx)
                        .onTapGesture {
                            self.actionModel.onVipBannerClick.send()
                        }
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        HomeActionView(
                            onItemClick: { actionType in
                                switch actionType {
                                case .Valuation:
                                    // 估值功能 - 启动相机进行估值
                                    FireBaseEvent.send(eventName: EventName.homeValuationClick)
                                    self.actionModel.onValuationClick.send()
                                case .Identify:
                                    // 识别功能 - 启动相机进行识别
                                    FireBaseEvent.send(eventName: EventName.homeIdentifyClick)
                                    self.actionModel.onIdentifyClick.send()
                                case .Detector:
                                    // 探测器功能 - 启动寻宝活动
                                    FireBaseEvent.send(eventName: EventName.homeDetectorClick)
                                    self.actionModel.onDetectorClick.send()
                                }
                            }
                        )
                        .padding(.horizontal, HomePageHorizontalPadding)
                        .padding(.top, 8.rpx)
                        .padding(.bottom, 12.rpx) // 增加底部间距，避免与下方元素重叠
                        .zIndex(1) // 确保按钮在最上层
                        .allowsHitTesting(true) // 明确允许触摸事件
                        
                        if let dailyStone = self.viewModel.dailyStones.first {
                            Button(action: {
                                self.actionModel.onDailyStoneClick.send(dailyStone.id)
                            }) {
                                HomeDailyStoneSectionView(
                                    stone: dailyStone,
                                    collected: self.viewModel.isCollected(id: dailyStone.id),
                                    onCollectClick: {
                                        self.actionModel.onDailyStoneCollectClick.send(dailyStone.id)
                                    },
                                    onShareClick: {
                                        self.actionModel.onDailyStoneShareClick.send(dailyStone.id)
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, HomePageHorizontalPadding)
                            .padding(.top, 20.rpx)
                            .zIndex(0) // 确保在按钮下层
                        }
                        
                        HomeNearStonesSectionView(
                            stones: self.viewModel.nearByStones,
                            onStoneClick: {
                                self.actionModel.onNearbyStoneItemClick.send($0.id)
                            },
                            onViewAllClick: {
                                self.actionModel.onNearbyStoneViewAllClick.send()
                            }
                        )
                        .padding(.top, 20.rpx)
                        
                        HomeAppUsageView()
                            .padding(.horizontal, HomePageHorizontalPadding)
                            .padding(.top, 24.rpx)
                            .padding(.bottom, 40.rpx)
                            .onTapGesture {
                                FireBaseEvent.send(eventName: EventName.homeInstructionsClick)
                                self.showingAppInstrcuctionPage = true
                                logEvent("home_appusage_click")
                            }
                    }
                }
            }
            .padding(.top, SafeTop)
        }
        .ignoresSafeArea()
        .id(refreshKey)
        .onReceive(NotificationCenter.default.publisher(for: LocalizationManager.languageChangedNotification)) { _ in
            refreshKey = UUID()
        }
        .fullScreenCover(isPresented: $showingAppInstrcuctionPage) {
            StoneInstructionPage(
                onBackClick: {
                    FireBaseEvent.send(eventName: EventName.instructionsCloseClick)
                    self.showingAppInstrcuctionPage = false
                },
                onIdentifyClick: {
                    FireBaseEvent.send(eventName: EventName.instructionsTakeClick)
                    self.showingAppInstrcuctionPage = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.actionModel.onIdentifyClick.send()
                    }
                }
            )
        }
    }
}

struct HomeSearchBar: View {
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 12.rpx) {
            Image("icon_search_22")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 22.rpx, height: 22.rpx)
            Text(Language.home_search_hint)
                .font(.system(size: 14.rpx))
                .lineSpacing(9.rpx)
                .foregroundColor(Color(hex: 0x687473, alpha: 0.8))
            Spacer()
        }
        .padding(.horizontal, 18.rpx)
        .frame(maxWidth: .infinity)
        .frame(height: 44.rpx)
        .background(Color.white.opacity(0.8))
        .cornerRadius(22.rpx)
        .padding(.horizontal, HomePageHorizontalPadding)
    }
}

struct HomeVipBanner: View {
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: 14.rpx)
            
            ZStack(alignment: .topTrailing) {
                Image("icon_vip_message")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 37.rpx, height: 29.rpx)
                    .padding(.top, 11.rpx)
                    .padding(.bottom, 8.rpx)
                    .padding(.trailing, 8.rpx)
                Image("icon_vip_message_badget")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 18.rpx, height: 20.rpx)
            }
            .frame(width: 45.rpx)
            
            Spacer()
                .frame(width: 12.rpx)
            
            Text(Language.home_vip_banner_text)
                .font(.system(size: 14.rpx, weight: .semibold))
                .lineSpacing(4.rpx)
                .foregroundColor(Color(hex: 0xECCD92))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
                .frame(width: 4.rpx)
            
            Image("icon_vip_banner_arrow_32")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 32.rpx, height: 32.rpx)
            
            Spacer()
                .frame(width: 6.rpx)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 68.rpx)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: 0x2A3D42),
                    Color(hex: 0x2E3449)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12.rpx)
    }
}


