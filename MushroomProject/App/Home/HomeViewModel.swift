import Combine
import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var showVipBanner: Bool = true
    @Published var dailyMushrooms: [SimpleMushroom] = []
    @Published var nearByMushrooms: [SimpleMushroom] = []
    @Published var dailyMushroomCollectedStates: [String: Bool] = [:] // id -> isCollected
    
    func loadData(completion: @escaping (Bool) -> ()) {
        self.showVipBanner = !LocalPurchaseManager.shared.isVIP
        Task {
            async let loadDailyMushroomsSuccess = await self.loadDailyMushroomsIfNeededAsync()
            async let loadRandomMushroomsSuccess = await self.loadNearbyMushroomsIfNeededAsync()
            
            let (dailySuccess, randomSuccess) = await (loadDailyMushroomsSuccess, loadRandomMushroomsSuccess)
            
            // 每次进入首页都重新加载收藏状态，确保数据及时更新
            if !dailyMushrooms.isEmpty {
                await self.loadCollectionStates()
            }
            
            if dailySuccess && randomSuccess {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    init() {
        // 监听VIP状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(vipStatusChanged),
            name: .VipInfoChanged,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func vipStatusChanged() {
        self.showVipBanner = !LocalPurchaseManager.shared.isVIP
    }
    
    private func loadDailyMushroomsIfNeededAsync() async -> Bool {
        if !self.dailyMushrooms.isEmpty {
            return true
        }
        let req = RandomMushroomRequest(lang:"en")
        let result: RandomMushroomResponse? = try? await ApiRequest.requestAsync(request: req)
        guard let stones = result?.mushrooms, !stones.isEmpty else {
            return false
        }
        self.dailyMushrooms = stones
        return true
    }
    
    private func loadNearbyMushroomsIfNeededAsync() async -> Bool {
        if !self.nearByMushrooms.isEmpty {
            return true
        }
        let req = NearByMushroomRequest(longitude: 0.0, latitude: 0.0)
        let result: NearByMushroomResponse? = try? await ApiRequest.requestAsync(request: req)
        guard let stones = result?.mushrooms, !stones.isEmpty else {
            return false
        }
        self.nearByMushrooms = stones
        return true
    }
    
    /// 加载每日石头的收藏状态
    private func loadCollectionStates() async {
        for stone in dailyMushrooms {
            await withCheckedContinuation { continuation in
                LocalRecordItem.isCollected(uid: stone.id) { [weak self] isCollected, success in
                    Task { @MainActor in
                        if success {
                            self?.dailyMushroomCollectedStates[stone.id] = isCollected
                        }
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    /// 刷新收藏状态（公开方法，可在需要时主动调用）
    func refreshCollectionStates() {
        Task {
            if !dailyMushrooms.isEmpty {
                await self.loadCollectionStates()
            }
        }
    }
    
    /// 切换收藏状态
    /// - Parameters:
    ///   - id: 石头 id
    ///   - completion: 完成回调
    func toggleCollectionState(id: String, completion: @escaping (Bool) -> Void) {
        guard let simpleMushroom = getMushroom(by: id) else {
            completion(false)
            return
        }
        LocalRecordItem.toggleCollected(stone: simpleMushroom) { [weak self] newState, success in
            Task { @MainActor in
                if success {
                    self?.dailyMushroomCollectedStates[id] = newState
                    // 任何收藏状态变更都通知其他页面刷新
                    NotificationCenter.default.post(name: .ReloadHistoryList, object: nil)
                }
                completion(success)
            }
        }
    }
    
    /// 获取指定 id 的收藏状态
    /// - Parameter id: 石头 id
    /// - Returns: 是否已收藏
    func isCollected(id: String) -> Bool {
        return dailyMushroomCollectedStates[id] ?? false
    }
    
    // MARK: - 辅助方法
    
    /// 根据id获取每日石头信息
    /// - Parameter id: 石头的唯一标识符
    /// - Returns: 对应的DailyMushroom对象，如果找不到则返回nil
    func getDailyMushroom(by id: String) -> SimpleMushroom? {
        return dailyMushrooms.first { $0.id == id }
    }
    
    /// 根据id获取附近蘑菇信息
    /// - Parameter id: 蘑菇的唯一标识符
    /// - Returns: 对应的SimpleMushroom对象，如果找不到则返回nil
    func getNearbyMushroom(by id: String) -> SimpleMushroom? {
        return nearByMushrooms.first { $0.id == id }
    }
    
    /// 根据id获取任意蘑菇信息（从所有列表中查找）
    /// - Parameter id: 蘑菇的唯一标识符
    /// - Returns: 对应的SimpleMushroom对象，如果找不到则返回nil
    func getMushroom(by id: String) -> SimpleMushroom? {
        if let dailyMushroom = getDailyMushroom(by: id) {
            // 需要将 DailyMushroom 转换为 SimpleMushroom
            return dailyMushroom
        }
        if let nearMushroom = getNearbyMushroom(by: id) {
            return nearMushroom
        }
        return nil
    }
}
