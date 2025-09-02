import Combine
import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var showVipBanner: Bool = true
    @Published var dailyStones: [DailyStone] = []
    @Published var nearByStones: [NearStone] = []
    @Published var dailyStoneCollectedStates: [String: Bool] = [:] // id -> isCollected
    
    func loadData(completion: @escaping (Bool) -> ()) {
        self.showVipBanner = !LocalPurchaseManager.shared.isVIP
        Task {
            async let loadDailyStonesSuccess = await self.loadDailyStonesIfNeededAsync()
            async let loadRandomStonesSuccess = await self.loadNearbyStonesIfNeededAsync()
            
            let (dailySuccess, randomSuccess) = await (loadDailyStonesSuccess, loadRandomStonesSuccess)
            
            // 每次进入首页都重新加载收藏状态，确保数据及时更新
            if !dailyStones.isEmpty {
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
    
    private func loadDailyStonesIfNeededAsync() async -> Bool {
        if !self.dailyStones.isEmpty {
            return true
        }
        let req = RandomStoneRequest(lang:"en")
        let result: DailyResponse? = try? await ApiRequest.requestAsync(request: req)
        guard let stones = result?.stones, !stones.isEmpty else {
            return false
        }
        self.dailyStones = stones
        return true
    }
    
    private func loadNearbyStonesIfNeededAsync() async -> Bool {
        if !self.nearByStones.isEmpty {
            return true
        }
        let req = NearByMushroomRequest(longitude: 0.0, latitude: 0.0)
        let result: NearByMushroomResponse? = try? await ApiRequest.requestAsync(request: req)
        guard let stones = result?.stones, !stones.isEmpty else {
            return false
        }
        self.nearByStones = stones
        return true
    }
    
    /// 加载每日石头的收藏状态
    private func loadCollectionStates() async {
        for stone in dailyStones {
            await withCheckedContinuation { continuation in
                LocalRecordItem.isCollected(uid: stone.id) { [weak self] isCollected, success in
                    Task { @MainActor in
                        if success {
                            self?.dailyStoneCollectedStates[stone.id] = isCollected
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
            if !dailyStones.isEmpty {
                await self.loadCollectionStates()
            }
        }
    }
    
    /// 切换收藏状态
    /// - Parameters:
    ///   - id: 石头 id
    ///   - completion: 完成回调
    func toggleCollectionState(id: String, completion: @escaping (Bool) -> Void) {
        guard let simpleStone = getStone(by: id) else {
            completion(false)
            return
        }
        LocalRecordItem.toggleCollected(stone: simpleStone) { [weak self] newState, success in
            Task { @MainActor in
                if success {
                    self?.dailyStoneCollectedStates[id] = newState
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
        return dailyStoneCollectedStates[id] ?? false
    }
    
    // MARK: - 辅助方法
    
    /// 根据id获取每日石头信息
    /// - Parameter id: 石头的唯一标识符
    /// - Returns: 对应的DailyStone对象，如果找不到则返回nil
    func getDailyStone(by id: String) -> DailyStone? {
        return dailyStones.first { $0.id == id }
    }
    
    /// 根据id获取附近石头信息
    /// - Parameter id: 石头的唯一标识符
    /// - Returns: 对应的NearStone对象，如果找不到则返回nil
    func getNearbyStone(by id: String) -> NearStone? {
        return nearByStones.first { $0.id == id }
    }
    
    /// 根据id获取任意石头信息（从所有列表中查找）
    /// - Parameter id: 石头的唯一标识符
    /// - Returns: 对应的SimpleStone对象，如果找不到则返回nil
    func getStone(by id: String) -> SimpleStone? {
        if let dailyStone = getDailyStone(by: id) {
            return dailyStone.toSimpleStone()
        }
        if let nearStone = getNearbyStone(by: id) {
            return nearStone.toSimpleStone()
        }
        return nil
    }
}
