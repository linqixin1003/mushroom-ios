import SwiftUI
import Combine
import Kingfisher

struct DetailActionModel {
    let navBackClick = PassthroughSubject<Void, Never>()
    let navCameraClick = PassthroughSubject<Void, Never>()
    let onViewMoreImagesClick = PassthroughSubject<[String], Never>()
    let bottomActionClick = PassthroughSubject<DetailBottomActionType, Never>()
    let onImageClick = PassthroughSubject<(Int,[String]), Never>()
}

struct DetailPage: View {
    @ObservedObject var viewModel: DetailViewModel
    let actionModel: DetailActionModel
    
    @State var showingMoreImagesPage: Bool = false
    
    var body: some View {
        AppPage(
            title: self.viewModel.stone?.name ?? "",
            leftButtonConfig: .init(imageName: "icon_back_24", onClick: {
                self.actionModel.navBackClick.send()
            }),
            rightButtonConfig: .init(imageName: "icon_camera_24", onClick: {
                self.actionModel.navCameraClick.send()
            })
        ) {
            VStack(spacing: 0) {
                if let stone = self.viewModel.stone {
                    ScrollView {
                        VStack(spacing: 0) {
                            let url: String = {
                                if self.viewModel.mediaType == .image, let headerUrl = self.viewModel.headerImageUrl {
                                    return headerUrl
                                } else {
                                    return stone.images.first ?? ""
                                }
                            }()
                            KFImage
                                .url(URL(string: url))
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth:.infinity, minHeight: 280.rpx, maxHeight: 280.rpx)
                                .clipped()
                                .onTapGesture {
                                    FireBaseEvent.send(eventName: EventName.detailMainImageClick, params: [EventParam.uid: stone.id])
                                    self.actionModel.onImageClick.send((0, [url]))
                                }
                            
                            MushroomSummaryView(
                                name: stone.name,
                                description: stone.description ?? "",
                                tags: (stone.tags ?? []).map { MushroomTag(id: 0, name: $0, slug: $0) }
                            )
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            
                            Spacer()
                                .frame(height: 12.rpx)
                            
                            VStack(spacing: 12.rpx) {
                                
                                if !stone.images.isEmpty {
                                    MushroomImagesSectionView(
                                        imageUrls: stone.images,
                                        onMoreClick: stone.images.count <= 2 ? nil : {
                                            FireBaseEvent.send(eventName: EventName.detailImageMoreClick, params: [EventParam.uid: stone.id])
                                            self.actionModel.onViewMoreImagesClick.send(stone.images)
                                            self.showingMoreImagesPage = true
                                        }) { position, imageUrl in
                                            FireBaseEvent.send(eventName: EventName.detailMainImageClick, params: [EventParam.uid: stone.id, EventParam.index: String(position)])
                                            self.actionModel.onImageClick.send((position, imageUrl))
                                        }
                                }
                                
                                // 化学属性区域
                                MushroomChemicalPropertiesSectionView(stone: stone)
                                
                                // 物理属性区域
                                MushroomPhysicalPropertiesSectionView(stone: stone)
                                
                                // 护理说明区域
                                if !(stone.storage ?? "").isEmpty || !(stone.cleaningTips ?? "").isEmpty {
                                    MushroomCareInstructionsSectionView(stone: stone)
                                }
                                
                                // 价格信息区域
                                if stone.pricePerCaratFrom != nil || stone.pricePerPoundFrom != nil {
                                    MushroomPriceSectionView(stone: stone)
                                }
                                
                                // 形而上学属性区域
                                if (stone.showMetaphysical ?? false) {
                                    MushroomMetaphysicalSectionView(stone: stone)
                                }
                                
                                // FAQ区域
                                if stone.faqs?.isEmpty == false {
                                    MushroomFAQSectionView(stone: stone)
                                }
                                
                                // 用途和健康信息区域
                                if !(stone.usage ?? "").isEmpty || (stone.healthRisks?.isEmpty == false) {
                                    MushroomUsageSectionView(stone: stone)
                                }
                            }
                            
                            Spacer()
                                .frame(height: 80)
                        }
                    }
                } else {
                    Spacer()
                }
                DetailBottomActionContainer(
                    canCollection: viewModel.canCollection(),
                    isInFavorite: viewModel.isInFavorite,
                    isInWish: viewModel.isInWish
                ) { type in
                    switch type {
                    case .new:
                        if let stone = self.viewModel.stone {
                            FireBaseEvent.send(eventName: EventName.detailRetakeClick, params: [EventParam.uid: stone.id])
                        }
                        self.actionModel.bottomActionClick.send(type)
                    case .addWish:
                        if let stone = self.viewModel.stone {
                            FireBaseEvent.send(eventName: EventName.detailWishClick, params: [EventParam.uid: stone.id])
                        }
                        self.actionModel.bottomActionClick.send(type)
                    case .save:
                        if let stone = self.viewModel.stone {
                            FireBaseEvent.send(eventName: EventName.detailSaveClick, params: [EventParam.uid: stone.id])
                        }
                        self.actionModel.bottomActionClick.send(type)
                    case .share:
                        if let stone = self.viewModel.stone {
                            FireBaseEvent.send(eventName: EventName.detailShareClick, params: [EventParam.uid: stone.id])
                        }
                        self.actionModel.bottomActionClick.send(type)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingMoreImagesPage) {
            if let imageUrls = self.viewModel.stone?.images {
                MoreImagePage(imageUrls: imageUrls, onCloseClick: {
                    self.showingMoreImagesPage = false
                }, onImageClick: { index in
                    self.actionModel.onImageClick.send((index, imageUrls))
                })
            }
        }
    }
}

struct MushroomSummaryView: View {
    
    let name: String
    let description: String
    let tags: [MushroomTag]
    
    @State private var expanded = false
    

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(self.name)
                .font(.semibold(28.rpx))
                .lineSpacing(2.rpx)
                .foregroundColor(.appText)
                .padding(.bottom, 6.rpx)

            if !description.isEmpty {
                ZStack(alignment: .bottomTrailing) {
                    Text(self.description)
                        .font(.regular(16.rpx))
                        .lineSpacing(4.rpx)
                        .foregroundColor(.appTextLight)
                        .lineLimit(expanded ? nil : 5)
                        .animation(.easeInOut, value: expanded)

                    if !expanded {
                        // "More >>" 按钮右下角悬挂显示
                        Button(action: {
                            expanded = true
                        }) {
                            HStack {
                                Text("...")
                                    .font(.regular(12.rpx))
                                    .lineSpacing(4.rpx)
                                    .foregroundColor(.appTextLight)
                                Text("\(Language.text_more)>>")
                                    .font(.regular(12.rpx))
                                    .lineSpacing(4.rpx)
                                    .foregroundColor(.primary)
                                    .padding(.trailing, 2)
                            }
                            .background(Color.white)
                        }
                    }
                }
                .padding(.bottom, 8.rpx)
            }
            
            if !tags.isEmpty {
                Text(tags.map { $0.name }.joined(separator: " • "))
                    .font(.regular(13.rpx))
                    .foregroundColor(.primary.opacity(0.8))
                    .fontWeight(.medium)
            }
        }
        .padding()
    }
}

struct MushroomSummaryView_Previews: PreviewProvider {
    
    static var previews: some View {
        MushroomSummaryView(
            name: "Jasper",
            description: "Jasper is a type of chalcedony mineral that is found in a variety of colors and patterns. It is often used for jewelry, carvings, and other decorative items.",
            tags: [MushroomTag(id: 1, name: "Healing", slug: "healing")]
        )
    }
}


struct MushroomImagesSectionView: View {
    
    let imageUrls: [String]
    let onMoreClick: (() -> Void)?
    let onImageClick: (Int, [String]) -> Void
    
    var body: some View {
        MushroomSectionContainerView(
            sectionTitle: Language.text_images,
            onMoreClick: self.onMoreClick,
            content: {
                HStack(spacing: 12.rpx) {
                    ForEach(0..<min(imageUrls.count, 3), id: \.self) { index in
                        KFImage
                            .url(URL(string: self.imageUrls[index]))
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fill)
                            .frame(width: 88.rpx, height: 88.rpx)
                            .clipped()
                            .cornerRadius(12.rpx)
                            .onTapGesture {
                                onImageClick(index, self.imageUrls)
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 6.rpx)
            }
        )
    }
}


struct MushroomSectionContainerView<Content>: View where Content: View {
    
    let sectionTitle: String
    let onMoreClick: (() -> Void)?
    let content: () -> Content
    
    
    var body: some View {
        VStack {
            HStack {
                Text(self.sectionTitle)
                    .font(.semibold(20.rpx))
                    .foregroundColor(.appText)
                Spacer()
                if let onMoreClick {
                    Button {
                        onMoreClick()
                    } label: {
                        HStack {
                            Text(Language.text_more)
                                .font(.regular(14.rpx))
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                            Image("icon_arrow_right")
                                .frame(width: 16.rpx, height: 16.rpx)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20.rpx)
            .padding(.bottom, 16.rpx)
            
            content()
        }
        .padding(.vertical, 20.rpx)
        .background(Color.white)
        .cornerRadius(16.rpx)
        .padding(.horizontal, 16.rpx)
    }
}

enum DetailBottomActionType: CaseIterable {
    case new        // 重拍
    case addWish    // 添加心愿单
    case save       // 收藏
    case share      // 分享

    var imageName: String {
        switch self {
        case .new:
            return "icon_camera_24"
        case .addWish:
            return "icon_heart_24_selected"
        case .save:
            return "icon_save_24"
        case .share:
            return "icon_share_24_2"
        }
    }

    var text: String {
        switch self {
        case .new:
            return Language.text_new
        case .addWish:
            return Language.profile_wishlist
        case .save:
            return Language.text_save
        case .share:
            return Language.text_share
        }
    }
}

struct DetailBottomActionContainer: View {
    let canCollection: Bool
    let isInFavorite: Bool
    let isInWish: Bool
    let onItemClick: (DetailBottomActionType) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部分割线
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.2))
            
            HStack(spacing: 0) {
                if canCollection && !isInFavorite {
                    // 未收藏状态：重拍和添加心愿单固定宽度，收藏按钮占剩余空间
                    ActionItemView(isInWish: isInWish, type: .new, onTap: { onItemClick(.new) })
                        .frame(width: 80) // 固定宽度，确保足够显示
                    
                    ActionItemView(isInWish: isInWish, type: .addWish, onTap: { onItemClick(.addWish) })
                        .frame(width: 80) // 固定宽度，确保足够显示
                    
                    // 收藏按钮 - 占剩余所有空间，主题色背景
                    Button(action: { onItemClick(.save) }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text(Language.add_to_collection)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.primary)
                        .cornerRadius(22)
                    }
                    .frame(maxWidth: .infinity) // 占据剩余所有空间
                    .padding(.horizontal, 6)
                } else {
                    // 已收藏或不能收藏状态：重拍、addWish、分享三个按钮平均分配
                    ActionItemView(isInWish: isInWish, type: .new, onTap: { onItemClick(.new) })
                        .frame(maxWidth: .infinity)
                    
                    ActionItemView(isInWish: isInWish, type: .addWish, onTap: { onItemClick(.addWish) })
                        .frame(maxWidth: .infinity)
                    
                    ActionItemView(isInWish: isInWish, type: .share, onTap: { onItemClick(.share) })
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 68)
            .padding(.horizontal, 16)
            .padding(.bottom, SafeBottom > 0 ? SafeBottom : 8)
            .background(Color.white)
        }
    }
}

// 单个Action按钮组件
struct ActionItemView: View {
    let isInWish: Bool
    let type: DetailBottomActionType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                // 图标
                if type == .addWish {
                    Image(isInWish ? "icon_heart_24_selected" : "icon_heart_24_normal")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(Color(hex: 0x666666))
                } else {
                    Image(type.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: 0x666666))
                }
                if type == .addWish{
                    // 文字
                    Text(isInWish ? Language.detail_del_wish : Language.detail_add_wish)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(hex: 0x666666))
                        .lineLimit(1)
                } else {
                    // 文字
                    Text(type.text)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(hex: 0x666666))
                        .lineLimit(1)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
