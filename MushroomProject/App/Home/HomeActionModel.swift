import Combine

struct HomeActionModel {
    let onSearchClick = PassthroughSubject<Void, Never>()
    let onVipBannerClick = PassthroughSubject<Void, Never>()
    let onIdentifyClick = PassthroughSubject<Void, Never>()
    // 新增：估价入口
    let onValuationClick = PassthroughSubject<Void, Never>()
    let onRecordClick = PassthroughSubject<Void, Never>()
    let onDetectorClick = PassthroughSubject<Void, Never>()
    let onDailyMushroomClick = PassthroughSubject<String, Never>()
    let onDailyMushroomCollectClick = PassthroughSubject<String, Never>()
    let onDailyMushroomShareClick = PassthroughSubject<String, Never>()
    let onNearbyMushroomItemClick = PassthroughSubject<String, Never>()
    let onNearbyMushroomViewAllClick = PassthroughSubject<Void, Never>()
    let onShareClick = PassthroughSubject<ShareData, Never>()
}
