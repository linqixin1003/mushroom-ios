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
            title: self.viewModel.mushroom?.commonName ?? "",
            leftButtonConfig: .init(imageName: "icon_back_24", onClick: {
                self.actionModel.navBackClick.send()
            }),
            rightButtonConfig: .init(imageName: "icon_camera_24", onClick: {
                self.actionModel.navCameraClick.send()
            })
        ) {
            VStack(spacing: 0) {
                if let mushroom = self.viewModel.mushroom {
                    ScrollView {
                        VStack(spacing: 0) {
                            let url: String = {
                                if self.viewModel.mediaType == .image, let headerUrl = self.viewModel.headerImageUrl {
                                    return headerUrl
                                } else {
                                    return mushroom.imageUrl ?? ""
                                }
                            }()
                            KFImage
                                .url(URL(string: url))
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth:.infinity, minHeight: 280.rpx, maxHeight: 280.rpx)
                                .clipped()
                                .onTapGesture {
                                    FireBaseEvent.send(eventName: EventName.detailMainImageClick, params: [EventParam.uid: mushroom.id])
                                    self.actionModel.onImageClick.send((0, [url]))
                                }
                            
                            MushroomSummaryView(
                                name: mushroom.name,
                                description: mushroom.description ?? "",
                                tags: mushroom.tags ?? []
                            )
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            
                            Spacer()
                                .frame(height: 12.rpx)
                            
                            VStack(spacing: 12.rpx) {
                                
                                if !(mushroom.imageUrl ?? "").isEmpty {
                                    MushroomImagesSectionView(
                                        imageUrls: [mushroom.imageUrl!],
                                        onMoreClick: {
                                            FireBaseEvent.send(eventName: EventName.detailImageMoreClick, params: [EventParam.uid: mushroom.id])
                                            self.actionModel.onViewMoreImagesClick.send([mushroom.imageUrl!])
                                            self.showingMoreImagesPage = true
                                        }) { position, imageUrl in
                                            FireBaseEvent.send(eventName: EventName.detailMainImageClick, params: [EventParam.uid: mushroom.id, EventParam.index: String(position)])
                                            self.actionModel.onImageClick.send((position, imageUrl))
                                        }
                                }
                                
                                // 科学名称
                                if let scientificName = mushroom.scientificName, !scientificName.isEmpty {
                                    MushroomSectionContainerView(
                                        sectionTitle: "Scientific Name",
                                        onMoreClick: nil
                                    ) {
                                        Text(scientificName)
                                            .font(.regular(14.rpx))
                                            .foregroundColor(.appTextLight)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 20.rpx)
                                    }
                                }
                                
                                // 概述
                                if let summary = mushroom.summary, !summary.isEmpty {
                                    MushroomSectionContainerView(
                                        sectionTitle: "Summary",
                                        onMoreClick: nil
                                    ) {
                                        ExpandableText(
                                            text: summary,
                                            lineLimit: 5
                                        )
                                        .padding(.horizontal, 20.rpx)
                                    }
                                }
                                
                                // 分类学信息
                                if let taxonomy = mushroom.taxonomy, !taxonomy.isEmpty {
                                    MushroomSectionContainerView(
                                        sectionTitle: "Taxonomy",
                                        onMoreClick: nil
                                    ) {
                                        ExpandableText(
                                            text: taxonomy,
                                            lineLimit: 3
                                        )
                                        .padding(.horizontal, 20.rpx)
                                    }
                                }
                                
                                // 形态特征
                                if let morphology = mushroom.morphology, !morphology.isEmpty {
                                    MushroomSectionContainerView(
                                        sectionTitle: "Morphology",
                                        onMoreClick: nil
                                    ) {
                                        ExpandableText(
                                            text: morphology,
                                            lineLimit: 5
                                        )
                                        .padding(.horizontal, 20.rpx)
                                    }
                                }
                                
                                // 生态环境
                                if let ecology = mushroom.ecology, !ecology.isEmpty {
                                    MushroomSectionContainerView(
                                        sectionTitle: "Ecology",
                                        onMoreClick: nil
                                    ) {
                                        ExpandableText(
                                            text: ecology,
                                            lineLimit: 5
                                        )
                                        .padding(.horizontal, 20.rpx)
                                    }
                                }
                                
                                // 栖息地与分布
                                if let habitat = mushroom.habitatAndDistribution, !habitat.isEmpty {
                                    MushroomSectionContainerView(
                                        sectionTitle: "Habitat & Distribution",
                                        onMoreClick: nil
                                    ) {
                                        ExpandableText(
                                            text: habitat,
                                            lineLimit: 5
                                        )
                                        .padding(.horizontal, 20.rpx)
                                    }
                                }
                                
                                // 可食用性
                                if let edibility = mushroom.edibility, !edibility.isEmpty {
                                    MushroomSectionContainerView(
                                        sectionTitle: "Edibility",
                                        onMoreClick: nil
                                    ) {
                                        ExpandableText(
                                            text: edibility,
                                            lineLimit: 3
                                        )
                                        .padding(.horizontal, 20.rpx)
                                    }
                                }
                                
                                // 毒性信息
                                if let toxicity = mushroom.toxicity, !toxicity.isEmpty {
                                    MushroomSectionContainerView(
                                        sectionTitle: "Toxicity Warning",
                                        onMoreClick: nil
                                    ) {
                                        VStack(alignment: .leading, spacing: 8.rpx) {
                                            // 毒性警告图标和标题
                                            HStack {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.orange)
                                                    .font(.system(size: 18.rpx))
                                                Text("Caution Required")
                                                    .font(.semibold(16.rpx))
                                                    .foregroundColor(.orange)
                                            }
                                            
                                            ExpandableText(
                                                text: toxicity,
                                                lineLimit: 5
                                            )
                                        }
                                        .padding(.horizontal, 20.rpx)
                                    }
                                }
                                
                                // 相似物种
                                if let similarSpecies = mushroom.similarSpecies, !similarSpecies.isEmpty {
                                    MushroomSectionContainerView(
                                        sectionTitle: "Similar Species",
                                        onMoreClick: nil
                                    ) {
                                        ExpandableText(
                                            text: similarSpecies,
                                            lineLimit: 5
                                        )
                                        .padding(.horizontal, 20.rpx)
                                    }
                                }
                                
                                // 识别要点
                                if let identification = mushroom.identification, !identification.isEmpty {
                                    MushroomSectionContainerView(
                                        sectionTitle: "Identification",
                                        onMoreClick: nil
                                    ) {
                                        ExpandableText(
                                            text: identification,
                                            lineLimit: 5
                                        )
                                        .padding(.horizontal, 20.rpx)
                                    }
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
                        if let mushroom = self.viewModel.mushroom {
                            FireBaseEvent.send(eventName: EventName.detailRetakeClick, params: [EventParam.uid: mushroom.id])
                        }
                        self.actionModel.bottomActionClick.send(type)
                    case .addWish:
                        if let mushroom = self.viewModel.mushroom {
                            FireBaseEvent.send(eventName: EventName.detailWishClick, params: [EventParam.uid: mushroom.id])
                        }
                        self.actionModel.bottomActionClick.send(type)
                    case .save:
                        if let mushroom = self.viewModel.mushroom {
                            FireBaseEvent.send(eventName: EventName.detailSaveClick, params: [EventParam.uid: mushroom.id])
                        }
                        self.actionModel.bottomActionClick.send(type)
                    case .share:
                        if let mushroom = self.viewModel.mushroom {
                            FireBaseEvent.send(eventName: EventName.detailShareClick, params: [EventParam.uid: mushroom.id])
                        }
                        self.actionModel.bottomActionClick.send(type)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingMoreImagesPage) {
            if let imageUrls = self.viewModel.mushroom?.imageUrl {
                MoreImagePage(imageUrls: [imageUrls], onCloseClick: {
                    self.showingMoreImagesPage = false
                }, onImageClick: { index in
                    self.actionModel.onImageClick.send((index, [imageUrls]))
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
