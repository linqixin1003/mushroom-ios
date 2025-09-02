import SwiftUI
import Combine
import UIKit

// 分享视图控制器包装器
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any] // 支持多种类型

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// 创建支持完成回调的分享视图
struct ShareSheetWithCompletion: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // 监听分享完成事件
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                // 分享成功，触发求好评检查
                AppReviewManager.shared.checkAndRequestReviewAfterShare()
                // 使用现有的事件名称，移除不存在的参数
                FireBaseEvent.send(eventName: EventName.mineItemShareClick, params: [
                    "completed": "true"
                ])
            }
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ProfilePage: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    let actionModel: ProfileActionModel
    
    @State private var selectedTab: Int = 0 // 0: 我的收藏, 1: 历史记录
    @State private var showSystemShareSheet = false
    @State private var currentShareItem: LocalRecordItem?
    @State private var refreshKey: UUID = UUID()
    
    // 获取当前显示的列表
    private func getCurrentDisplayList() -> [LocalRecordItem] {
        switch selectedTab {
        case 0:
            return viewModel.collectionList
        case 1:
            return viewModel.historyList
        default:
            return []
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: 0xDA8E46),
                    Color(hex: 0xAF9783).opacity(0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280.rpx)
            
            VStack(spacing: 0) {

                 HStack {
                    Text(Language.profile_me)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 12) {
                        Image("icon_share")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Circle())
                            .onTapGesture {
                                self.actionModel.shareClick.send()
                            }
                        Image("icon_setting")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Circle())
                            .onTapGesture {
                                self.actionModel.settingsClick.send()
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                if !PersistUtil.isVip {
                    // VIP Privileges Banner
                    HStack {
                        HStack(spacing: 8) {
                            Image("icon_setting_vip")
                                .resizable()
                                .frame(width: 28, height: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Language.profile_vip)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(red: 1, green: 0.89, blue: 0.67))
                                Text(Language.profile_privileges)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 1, green: 0.89, blue: 0.67).opacity(0.8))
                            }
                        }
                        Spacer()
                        Button(action: {
                            print("onVipBannerClick")
                            self.actionModel.onVipBannerClick.send()
                        }) {
                            Text(Language.profile_subscribe_now)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.32, green: 0.22, blue: 0.09))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 8)
                                .background(Color(red: 1, green: 0.89, blue: 0.67))
                                .cornerRadius(18)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(red: 0.13, green: 0.18, blue: 0.23), Color(red: 0.18, green: 0.22, blue: 0.28)]), startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }

                // Tab切换
                HStack {
                    Spacer()
                    Button(action: {
                        selectedTab = 0
                        FireBaseEvent.send(eventName: EventName.mineCollectionClick)
                    }) {
                        Text(String(format: Language.profile_my_collection, viewModel.collectionList.count))
                            .font(.system(size: 14))
                            .fontWeight(selectedTab == 0 ? .bold : .regular)
                            .foregroundColor(selectedTab == 0 ? .primary: .black)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        selectedTab = 1
                        FireBaseEvent.send(eventName: EventName.mineHistoryClick)
                        // 如果历史记录为空，触发加载
                        if viewModel.historyList.isEmpty && !viewModel.isLoading {
                            Task {
                                await viewModel.refreshHistory()
                            }
                        }
                    }) {
                        Text(String(format: Language.profile_history_record, viewModel.historyList.count))
                            .font(.system(size: 14))
                            .fontWeight(selectedTab == 2 ? .bold : .regular)
                            .foregroundColor(selectedTab == 2 ? .primary: .black)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24.rpx)
                .padding(.top, 16.rpx)
                .padding(.bottom, 8.rpx)
                .background(Color.white)
                .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                
                // 内容区
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // 下拉刷新提示
                        if viewModel.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text(Language.profile_refreshing)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 10)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(getCurrentDisplayList()) { item in
                                CollectionItemView(
                                    model: item,
                                onDelete: { deletedItem in
                                    FireBaseEvent.send(eventName: EventName.mineItemDeleteClick, params: [EventParam.uid: item.uid])
                                    // 使用 Task 来调用异步函数
                                    Task {
                                        let success = await viewModel.deleteItem(
                                            deletedItem, 
                                            isCollection: selectedTab == 0
                                        )
                                        if success {
                                            viewModel.showDeleteSuccess = true
                                        } else {
                                            viewModel.showDeleteFail = true
                                        }
                                        
                                        // 延迟1.5秒后自动隐藏提示
                                        try? await Task.sleep(for: .seconds(1.5))
                                        viewModel.showDeleteSuccess = false
                                        viewModel.showDeleteFail = false
                                    }
                                },
                                    onShare: { sharedItem in
                                        FireBaseEvent.send(eventName: EventName.mineItemShareClick, params: [EventParam.uid: item.uid])
                                        print("Share data: \(sharedItem.mediaUrl), \(sharedItem.commonName)")
                                        currentShareItem = sharedItem
                                    },
                                    onItemClick: { clickedItem in
                                        actionModel.onItemClick.send(ProfileItemClickData(
                                            uid: clickedItem.uid,
                                            url: clickedItem.mediaUrl,
                                            type: clickedItem.type,
                                            identificationId: clickedItem.identificationId
                                        ))
                                    }
                                )
                                .onAppear {
                                    // 根据不同tab触发加载更多
                                    if selectedTab == 1 {
                                        // 历史记录tab
                                        let currentList = viewModel.historyList
                                        let currentIndex = currentList.firstIndex(where: { $0.id == item.id }) ?? 0
                                        let threshold = max(currentList.count - 4, 0) // 提前4个item开始加载
                                        
                                        if currentIndex >= threshold,
                                           viewModel.hasMoreData && !viewModel.isLoadingMore {
                                            Task {
                                                await viewModel.loadMoreHistory()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 加号按钮
                            AddMoreCardView(
                                onTap: {
                                    FireBaseEvent.send(eventName: EventName.mineAddMoreClick)
                                    actionModel.onAddMoreClick.send(selectedTab) // 传递当前选中的tab
                                }
                            )
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 8)
                        
                        // 加载更多指示器（心愿单和历史记录tab显示）
                        if selectedTab == 1 {
                            // 历史记录tab
                            if viewModel.isLoadingMore {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text(Language.profile_load_more)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 20)
                            } else if viewModel.hasMoreData && !viewModel.historyList.isEmpty {
                                // 加载更多按钮
                                Button(action: {
                                    Task {
                                        await viewModel.loadMoreHistory()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.down.circle")
                                            .foregroundColor(Color(hex: 0x00A796))
                                        Text(Language.profile_load_more_button)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: 0x00A796))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                }
                                .padding(.vertical, 20)
                            } else if !viewModel.hasMoreData && !viewModel.historyList.isEmpty {
                                Text(Language.profile_no_more_data)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 20)
                            }
                        }
                    }
                    .background(Color(hex: 0xF5F5F5))
                    .refreshable {
                        // 下拉刷新
                        switch selectedTab {
                        case 1:
                            await viewModel.refreshHistory()
                        default:
                            // 刷新收藏列表
                            viewModel.loadData { _ in }
                        }
                    }
                }
            }
            .padding(.top, 50)
            .fullScreenCover(item: $currentShareItem) { item in
                ShareView(
                    viewModel: ShareViewModel(
                        url: item.mediaUrl,
                        name: item.commonName
                    ),
                    onBack: { currentShareItem = nil }
                )
            }
            .sheet(isPresented: $showSystemShareSheet) {
                if let item = currentShareItem {
                    if let url = URL(string: item.mediaUrl) {
                        // 分享图片链接
                        ShareSheetWithCompletion(items: [url, item.commonName])
                    }
                }
            }
        }
        .ignoresSafeArea()
        .id(refreshKey)
        .onReceive(NotificationCenter.default.publisher(for: LocalizationManager.languageChangedNotification)) { _ in
            refreshKey = UUID()
        }
    }
}

// MARK: - 预览
struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        // 创建测试数据
        let viewModel = ProfileViewModel()
        let actionModel = ProfileActionModel()
        
        // 添加一些测试数据
        viewModel.collectionList = [
            LocalRecordItem(
                id: "1",
                uid: "user1",
                type: .image,
                createdAt: "2024-03-10T10:00:00Z",
                confidence: 0.95,
                latinName: "Turdus merula",
                commonName: "Eurasian Blackmushroom",
                mediaUrl: "https://images.pexels.com/photos/1661179/pexels-photo-1661179.jpeg"
            ),
            LocalRecordItem(
                id: "3",
                uid: "user1",
                type: .image,
                createdAt: "2024-03-10T09:30:00Z",
                confidence: 0.91,
                latinName: "Erithacus rubecula",
                commonName: "European Robin",
                mediaUrl: "https://images.pexels.com/photos/1661179/pexels-photo-1661179.jpeg"
            ),
            LocalRecordItem(
                id: "5",
                uid: "user1",
                type: .image,
                createdAt: "2024-03-09T16:20:00Z",
                confidence: 0.94,
                latinName: "Carduelis carduelis",
                commonName: "European Goldfinch",
                mediaUrl: "https://images.pexels.com/photos/1661179/pexels-photo-1661179.jpeg"
            )
        ]
        
        viewModel.historyList = [
            LocalRecordItem(
                id: "6",
                uid: "user1",
                type: .image,
                createdAt: "2024-03-09T15:00:00Z",
                confidence: 0.92,
                latinName: "Parus major",
                commonName: "Great Tit",
                mediaUrl: "https://images.pexels.com/photos/1661179/pexels-photo-1661179.jpeg"
            ),
            LocalRecordItem(
                id: "8",
                uid: "user1",
                type: .image,
                createdAt: "2024-03-09T13:15:00Z",
                confidence: 0.93,
                latinName: "Passer domesticus",
                commonName: "House Sparrow",
                mediaUrl: "https://images.pexels.com/photos/1661179/pexels-photo-1661179.jpeg"
            ),
            LocalRecordItem(
                id: "10",
                uid: "user1",
                type: .image,
                createdAt: "2024-03-09T11:45:00Z",
                confidence: 0.90,
                latinName: "Sturnus vulgaris",
                commonName: "Common Starling",
                mediaUrl: "https://images.pexels.com/photos/1661179/pexels-photo-1661179.jpeg"
            )
        ]
        
        return ProfilePage(viewModel: viewModel, actionModel: actionModel)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Profile Page")
    }
}

