import SwiftUI
import Combine
import Kingfisher

struct SearchActionModel {
    let resultItemClick = PassthroughSubject<SimpleMushroom, Never>()
}

struct SearchPage: View {
    @ObservedObject var viewModel: SearchViewModel
    let actionModel: SearchActionModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            HStack {
                Button(action: {
                    FireBaseEvent.send(eventName: EventName.searchCloseClick)
                    dismiss()
                }) {
                    Image("icon_back_24")
                        .frame(width: 44.0, height: 44.0)
                }
                
                HStack {
                    Image("icon_search_22")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 22.rpx, height: 22.rpx)
                    TextField(Language.home_search_hint, text: $searchText)
                        .onChange(of: searchText) { newValue in
                            viewModel.search(query: newValue)
                        }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .frame(height: 44.rpx)
                .background(Color(hex: 0xE0E6E5).opacity(0.8))
                .cornerRadius(22.rpx)
            }
            .padding(.top, SafeTop)
            .padding(.bottom, 6.rpx)
            .padding(.leading, 6.rpx)
            .padding(.trailing, 24.rpx)
            .background(Color.white)
            if searchText.isEmpty{
                ZStack(alignment: .center, content: {
                    Text(Language.search_enter_keywords)
                        .font(.regular(14.rpx))
                        .foregroundColor(.appTextLight)
                        .padding(.horizontal, 60.rpx)
                        .multilineTextAlignment(.center)
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.searchResults.isEmpty && !viewModel.isLoading {
                VStack(){
                    Image("icon_search_empty_list")
                        .frame(width: 172.rpx, height: 172.rpx, alignment: .center)
                    Text(Language.search_no_search)
                        .font(.regular(14.rpx))
                        .foregroundColor(.appTextLight)
                        .padding(.horizontal, 60.rpx)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 搜索结果列表
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.searchResults) { mushroom in
                            SearchResultItemView(
                                mushroom: mushroom
                            )
                            .id(mushroom.id)
                            .onTapGesture {
                                self.actionModel.resultItemClick.send(mushroom)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
    }
}

struct SearchResultItemView: View {
    
    let mushroom: SimpleMushroom
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 22.rpx) {
                KFImage
                    .url(URL(string: mushroom.photoUrl ?? ""))
                    .resizable()
                    .placeholder {
                        Image("icon_placeholder_68")
                            .resizable()
                            .scaledToFill()
                    }
                    .aspectRatio(1.0, contentMode: .fill)
                    .frame(width: 68.rpx, height: 68.rpx)
                    .clipped()
                    .cornerRadius(6.rpx)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(self.mushroom.name)
                        .font(.regular(16.rpx))
                        .lineSpacing(2.rpx)
                        .foregroundColor(.appText)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(self.mushroom.scientificName ?? "")
                        .font(.regular(16.rpx))
                        .italic()
                        .lineSpacing(2.rpx)
                        .foregroundColor(.appTextLight)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 16.rpx)
            .padding(.vertical, 14.rpx)
            
            Rectangle()
                .foregroundColor(Color(hex: 0x868686).opacity(0.1))
                .frame(maxWidth: .infinity)
                .frame(height: 1.rpx)
                .padding(.horizontal, 24.rpx)
        }
        .frame(maxWidth: .infinity)
    }
}
