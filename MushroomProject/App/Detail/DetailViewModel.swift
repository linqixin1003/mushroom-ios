import Combine
import AVFoundation
import Waveform

class DetailViewModel: ObservableObject {
    var id: String = ""
    var headerImageUrl: String? = nil
    var mediaType: LocalRecordType? = nil
    
    @Published var mushroom: Mushroom? = nil
    @Published var isInWish: Bool = false
    @Published var isInFavorite: Bool = false
    var identificationId:Int? = nil
    
    func canCollection() -> Bool{
        return identificationId != nil && !isInFavorite
    }
    func loadData() {
        LoadingUtil.showLoading()
        Task {
            let req = GetDetailRequest(mushroomId: self.id, language: "en")
            let result: GetDetailResponse? = try? await ApiRequest.requestAsync(request: req)
            await MainActor.run {
                LoadingUtil.dismiss()
                guard let result else {
                    ToastUtil.showToast(Language.text_common_error_try_again)
                    return
                }
                self.mushroom = result.mushroom
                self.isInWish = result.isInWishlist
                print("🔍 Mushroom isInWish from server: \(result.isInWishlist)")
            }
        }
    }
}
