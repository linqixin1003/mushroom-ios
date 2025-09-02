import Combine

struct HomeActionModel {
    let onSearchClick = PassthroughSubject<Void, Never>()
    let onVipBannerClick = PassthroughSubject<Void, Never>()
    let onIdentifyClick = PassthroughSubject<Void, Never>()
    // 新增：估价入口
    let onValuationClick = PassthroughSubject<Void, Never>()
    let onRecordClick = PassthroughSubject<Void, Never>()
    let onDetectorClick = PassthroughSubject<Void, Never>()
    let onDailyStoneClick = PassthroughSubject<String, Never>()
    let onDailyStoneCollectClick = PassthroughSubject<String, Never>()
    let onDailyStoneShareClick = PassthroughSubject<String, Never>()
    let onNearbyStoneItemClick = PassthroughSubject<String, Never>()
    let onNearbyStoneViewAllClick = PassthroughSubject<Void, Never>()
    let onShareClick = PassthroughSubject<ShareData, Never>()
}
