import Combine
import SwiftUI
import MessageUI
class SuggestionViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var desc: String = ""
    @Published private(set) var isSendEnable: Bool = false
    @Published var images: [UIImage] = []
    @Published var showingImagePicker = false
    @Published var imageSelect = false
    init(){
        $email.combineLatest($desc)
           .map { !$0.isEmpty && !$1.isEmpty }
           .assign(to: &$isSendEnable)
    }

    func getImage(_ index: Int) -> UIImage? {
        return (index >= images.count) ? nil : images[index]
    }
}
