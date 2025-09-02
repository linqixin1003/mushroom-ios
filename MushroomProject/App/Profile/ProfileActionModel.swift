import Combine

struct ProfileItemClickData {
    let uid: String
    let url: String
    let type: LocalRecordType
    var identificationId:Int? = nil
}

struct ProfileActionModel {
    let shareClick = PassthroughSubject<Void, Never>()
    let settingsClick = PassthroughSubject<Void, Never>()
    let onVipBannerClick = PassthroughSubject<Void, Never>()
    let onItemClick = PassthroughSubject<ProfileItemClickData, Never>()
    let onAddMoreClick = PassthroughSubject<Int, Never>() // 传递当前选中的tab（0: 收藏, 1:心愿单, 2: 历史）
} 
