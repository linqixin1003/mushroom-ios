import Combine
import Alamofire
import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var showVipBanner: Bool = true
    @Published var identifications: [IdentificationRecord] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    @Published var collectionList: [LocalRecordItem] = []
    @Published var historyList: [LocalRecordItem] = []
    @Published var wishListItems: [LocalRecordItem] = []
    
    // 心愿单分页相关属性
    @Published var isLoadingMoreWishList: Bool = false
    @Published var hasMoreWishListData: Bool = true
    @Published var currentWishListPage: Int = 0
    
    // 添加删除状态属性
    @Published var showDeleteSuccess: Bool = false
    @Published var showDeleteFail: Bool = false
    
    // 分页相关属性
    @Published var isLoadingMore: Bool = false
    @Published var hasMoreData: Bool = true
    @Published var currentPage: Int = 0
    private let pageSize: Int = 20
    
    
    
    
    // 添加合并和排序方法
    private func updateHistoryList() {
        var combined: [LocalRecordItem] = []
        
        // 转换图片识别记录
        combined.append(contentsOf: identifications.map { LocalRecordItem.fromImage($0) })
        
        // 按时间排序（假设createdAt是ISO 8601格式的日期字符串）
        combined.sort { (record1, record2) -> Bool in
            return record1.createdAt > record2.createdAt // 降序排列，最新的在前面
        }
        
        // 更新合并后的记录
        self.historyList = combined
    }
    
    func loadData(completion: @escaping (Bool) -> ()) {
        self.showVipBanner = !PersistUtil.isVip
        Task {
            // 同时启动所有加载任务
            async let loadIdentificationsSuccess = self.loadIdentificationHistoryAsync()
            async let loadCollectionSuccess = self.loadCollectionItemsAsync()
            async let loadWishListSuccess = self.loadWishListAsync()
            
            // 只等待网络请求的结果
            let identificationsSuccess = await loadIdentificationsSuccess
            let collectionSuccess = await loadCollectionSuccess
            let wishListSuccess = await loadWishListSuccess
            
            // 更新历史记录并立即回调
            if identificationsSuccess && collectionSuccess && wishListSuccess {
                self.updateHistoryList()
                completion(true)
            } else {
                completion(false)
            }
            
        }
    }
    
    private func loadCollectionItemsAsync() async -> Bool {
        do {
            let request = ListCollectionRequest()
            let response: ListCollectionResponse? = try await ApiRequest.requestAsync(request: request)
            
            guard let collectionResponse = response else {
                DispatchQueue.main.async {
                    self.collectionList = []
                }
                return false
            }
            
            // 将服务器返回的CollectionRecord转换为LocalRecordItem
            let localItems = collectionResponse.items.map { $0.toLocalRecordItem() }
            
            DispatchQueue.main.async {
                self.collectionList = localItems
            }
            
            return true
        } catch {
            print("❌ Load collection failed: \(error)")
            DispatchQueue.main.async {
                self.collectionList = []
            }
            return false
        }
    }
    
    private func loadIdentificationHistoryAsync() async -> Bool {
        let req = ListIdentificationsRequest(limit: pageSize, offset: 0, lang: "en")
        do {
            let result: ListIdentificationsResponse? = try await ApiRequest.requestAsync(request: req)
            guard let records = result?.identifications else {
                return false
            }
            self.identifications = records
            self.currentPage = 0
            self.hasMoreData = records.count >= pageSize
            return true
        } catch {
            // 打印具体的网络错误，方便调试
            print("❌ \(Language.debug_load_image_history_failed): \(error.localizedDescription)")
            // 可以在这里更新UI，比如显示一个错误信息
            self.error = Language.profile_error_load_history
            return false
        }
    }
    
    // 加载更多历史记录
    func loadMoreHistory() async {
        guard !isLoadingMore && hasMoreData else { return }
        
        isLoadingMore = true
        let nextPage = currentPage + 1
        let offset = nextPage * pageSize
        
        let req = ListIdentificationsRequest(limit: pageSize, offset: offset, lang: "en")
        
        do {
            let result: ListIdentificationsResponse? = try await ApiRequest.requestAsync(request: req)
            guard let newRecords = result?.identifications else {
                isLoadingMore = false
                return
            }
            
            // 添加新记录到现有列表
            self.identifications.append(contentsOf: newRecords)
            self.currentPage = nextPage
            self.hasMoreData = newRecords.count >= pageSize
            
            // 更新合并后的历史记录
            self.updateHistoryList()
            
        } catch {
            print("❌ Failed to load more history: \(error.localizedDescription)")
            self.error = Language.profile_error_load_more_data
        }
        
        isLoadingMore = false
    }
    
    // 刷新历史记录
    func refreshHistory() async {
        currentPage = 0
        hasMoreData = true
        identifications.removeAll()
        
        let success = await loadIdentificationHistoryAsync()
        if success {
            updateHistoryList()
        }
    }
    
    
    // 添加模拟数据方法
    private func mockData() {
        // 模拟图片识别记录
        self.identifications = [
            IdentificationRecord(
                id: 101,
                userId: "test-user",
                stoneId: "stone-1",
                name: "Test Stone 1",
                imageUrl: "https://example.com/image1.jpg",
                confidence: 0.95,
                source: "test",
                createdAt: "2024-01-01T00:00:00Z"
            ),
            IdentificationRecord(
                id: 102,
                userId: "test-user",
                stoneId: "stone-2",
                name: "Test Stone 2",
                imageUrl: "https://example.com/image2.jpg",
                confidence: 0.88,
                source: "test",
                createdAt: "2024-01-02T00:00:00Z"
            ),
            IdentificationRecord(
                id: 103,
                userId: "test-user",
                stoneId: "stone-3",
                name: "Test Stone 3",
                imageUrl: "https://example.com/image3.jpg",
                confidence: 0.92,
                source: "test",
                createdAt: "2024-01-03T00:00:00Z"
            )
        ]
        
        
        // 更新合并后的记录
        self.updateHistoryList()
    }
    
    // 添加一个用于测试的方法
    func loadMockData() {
        mockData()
    }
    // 加载心愿单
    func loadWishListAsync() async -> Bool {
        let req = GetWishListRequest(limit: pageSize, offset: 0, lang: "en")
        do {
            let result: GetWishListResponse? = try await ApiRequest.requestAsync(request: req)
            guard let items = result?.items else {
                return false
            }
            // 转换为LocalRecordItem统一数据结构
            self.wishListItems = items.map { wishItem in
                LocalRecordItem(
                    id: String(wishItem.id),
                    uid: wishItem.stoneId,
                    type: .image,
                    createdAt: wishItem.createdAt,
                    confidence: 1.0,
                    latinName: wishItem.name,
                    commonName: wishItem.name,
                    mediaUrl: wishItem.photoUrl ?? ""
                )
            }
            self.currentWishListPage = 0
            self.hasMoreWishListData = items.count >= pageSize
            return true
        } catch {
            print("❌ Failed to load wishlist: \(error.localizedDescription)")
            self.error = Language.profile_error_load_wishlist
            return false
        }
    }
    
    // 加载更多心愿单
    func loadMoreWishList() async {
        guard !isLoadingMoreWishList && hasMoreWishListData else { return }
        
        isLoadingMoreWishList = true
        let nextPage = currentWishListPage + 1
        let offset = nextPage * pageSize
        
        let req = GetWishListRequest(limit: pageSize, offset: offset, lang: "en")
        
        do {
            let result: GetWishListResponse? = try await ApiRequest.requestAsync(request: req)
            guard let newItems = result?.items else {
                isLoadingMoreWishList = false
                return
            }
            
            // 转换并添加新记录到现有列表
            let newRecordItems = newItems.map { wishItem in
                LocalRecordItem(
                    id: String(wishItem.id),
                    uid: wishItem.stoneId,
                    type: .image,
                    createdAt: wishItem.createdAt,
                    confidence: 1.0,
                    latinName: wishItem.name,
                    commonName: wishItem.name,
                    mediaUrl: wishItem.photoUrl
                )
            }
            
            self.wishListItems.append(contentsOf: newRecordItems)
            self.currentWishListPage = nextPage
            self.hasMoreWishListData = newItems.count >= pageSize
            
        } catch {
            print("❌ Failed to load more wishlist: \(error.localizedDescription)")
            self.error = Language.profile_error_load_more_wishlist
        }
        
        isLoadingMoreWishList = false
    }
    
    // 刷新心愿单
    func refreshWishList() async {
        currentWishListPage = 0
        hasMoreWishListData = true
        wishListItems.removeAll()
        
        let success = await loadWishListAsync()
        if !success {
            print("❌ Failed to refresh wishlist")
        }
    }
    
    // 从心愿单删除
    func removeFromWishList(itemId: String) async -> Bool {
        let req = RemoveFromWishListRequest(itemId: itemId)
        do {
            let result: RemoveFromWishListResponse = try await ApiRequest.requestAsync(request: req)
            if result.success {
                self.wishListItems.removeAll { $0.id == itemId }
                return true
            }
            return false
        } catch {
            print("❌ Failed to delete from wishlist: \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteItem(_ item: LocalRecordItem, isCollection: Bool, isWishList: Bool = false) async -> Bool {
        if isWishList {
            return await removeFromWishList(itemId: item.id)
        } else if isCollection {
            // 从服务器删除收藏项目
            do {
                // 提取真实的收藏ID（去掉"collection_"前缀）
                let realId = item.id.hasPrefix("collection_") ? String(item.id.dropFirst("collection_".count)) : item.id
                let collectionId = Int(realId) ?? 0
                let req = DeleteCollectionRequest(collectionId: collectionId)
                let result: DeleteCollectionResponse = try await ApiRequest.requestAsync(request: req)
                
                if result.success {
                    // 从本地列表中移除
                    if let index = collectionList.firstIndex(where: { $0.id == item.id }) {
                        collectionList.remove(at: index)
                    }
                    print("✅ Delete collection success")
                    return true
                } else {
                    print("❌ Delete collection failed: \(result.message)")
                    return false
                }
            } catch {
                print("❌ Delete collection failed: \(error)")
                return false
            }
        } else {
            guard let index = historyList.firstIndex(where: { $0.id == item.id }) else {
                return false
            }
            historyList.remove(at: index)
            
            // 使用 do-catch 处理异步网络请求
            do {
                let req = DeleteIdentificationRequest(identifyId: item.id)
                let _: DeleteIdentificationResponse = try await ApiRequest.requestAsync(request: req)
                print("✅ Delete identification record success")
                return true
            } catch {
                print("❌ Delete identification record failed: \(error)")
                return false
            }
        }
    }
}
