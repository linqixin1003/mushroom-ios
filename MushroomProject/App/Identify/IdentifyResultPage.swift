import UIKit
import SwiftUI
import Combine
import Kingfisher

struct IdentifyResultActionModel {
    let navBackClick = PassthroughSubject<Void, Never>()
    let navCameraClick = PassthroughSubject<Void, Never>()
    let onViewMoreImagesClick = PassthroughSubject<[String], Never>()
    let bottomActionClick = PassthroughSubject<DetailBottomActionType, Never>()
    let onImageClick = PassthroughSubject<(Int,[String]), Never>()
    let onChangeResultClick = PassthroughSubject<Int, Never>()
}

struct IdentifyResultPage: View {
    let mushroom: Mushroom
    let images:[String]
    var isInWish: Bool
    var isInFavorite:Bool = false
    let actionModel: IdentifyResultActionModel
    let capturedImage: UIImage?
    @State var showingMoreImagesPage: Bool = false
    @State private var showingSharePage: Bool = false
    @State private var compareImageUrl: String? = nil

    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.resultOpen, closeEventName: EventName.resultClose)
    var body: some View {
        AppPage(
            title: self.mushroom.name,
            leftButtonConfig: .init(imageName: "icon_back_24", onClick: {
                self.actionModel.navBackClick.send()
            }),
            rightButtonConfig: .init(imageName: "icon_camera_24", onClick: {
                self.actionModel.navCameraClick.send()
            })
        ) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // 使用TabView封装后的图片分页（指示器覆盖在图片底部）
                        ImageTabView(
                            imageUrls: images,
                            capturedImage: capturedImage,
                            mushroom: mushroom,
                            actionModel: actionModel) { url, image in
                                self.compareImageUrl = url
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
                                        FireBaseEvent.send(eventName: EventName.resultImageMoreClick, params: [EventParam.uid: self.mushroom.id])
                                        self.actionModel.onViewMoreImagesClick.send([mushroom.imageUrl!])
                                        self.showingMoreImagesPage = true
                                    }) { position, imageUrl in
                                        FireBaseEvent.send(eventName: EventName.resultViewImageClick, params: [EventParam.uid: self.mushroom.id, EventParam.index: String(position)])
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
                DetailBottomActionContainer(
                    canCollection: true,
                    isInFavorite: isInFavorite,
                    isInWish: isInWish,
                ) { type in
                    switch type {
                    case .new:
                        FireBaseEvent.send(eventName: EventName.resultRetakeClick, params: [EventParam.uid: self.mushroom.id, EventParam.index: "1"])
                        self.actionModel.bottomActionClick.send(type)
                    case .save:
                        FireBaseEvent.send(eventName: EventName.resultSaveClick, params: [EventParam.uid: self.mushroom.id])
                        self.actionModel.bottomActionClick.send(type)
                    case .share:
                        FireBaseEvent.send(eventName: EventName.resultShareClick, params: [EventParam.uid: self.mushroom.id])
                        self.handleShareAction()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingMoreImagesPage) {
            MoreImagePage(imageUrls: [mushroom.imageUrl ?? ""], onCloseClick: {
                self.showingMoreImagesPage = false
            }, onImageClick: { index in
                self.actionModel.onImageClick.send((index, [mushroom.imageUrl ?? ""]))
            })
        }
        .fullScreenCover(isPresented: $showingSharePage) {
            ShareView(
                viewModel: ShareViewModel(
                    image: capturedImage,
                    name: mushroom.name
                ),
                onBack: {
                    self.compareImageUrl = nil
                }
            )
        }
        .fullScreenCover(isPresented: .constant(shouldShowCompareImage)) {
            if let imageUrl = compareImageUrl {
                CompareImagePage(
                    referenceImageUrl: imageUrl,
                    capturedImage: capturedImage,
                    onCloseClick: {
                        self.compareImageUrl = nil
                    }
                )
            }
        }
    }
    
    private func handleShareAction() {
        self.showingSharePage = true
    }
    
    private var shouldShowCompareImage: Bool {
        compareImageUrl != nil
    }
}

extension MushroomObservation {
    init(from observation: Observation) {
        self.id = observation.id
        self.colors = MushroomColors(
            black: observation.black,
            blue: observation.blue,
            brown: observation.brown,
            gray: observation.gray,
            green: observation.green,
            orange: observation.orange,
            red: observation.red,
            white: observation.white,
            yellow: observation.yellow
        )
        self.environment = MushroomEnvironment(
            feeder: observation.feeder,
            fence: observation.fence,
            ground: observation.ground,
            trees: observation.trees,
            water: observation.water
        )
        self.behavior = MushroomBehavior(
            flying: observation.flying
        )
        self.size = MushroomSize(
            size1: observation.size1,
            size2: observation.size2,
            size3: observation.size3,
            size4: observation.size4,
            size5: observation.size5,
            size6: observation.size6,
            size7: observation.size7
        )
        self.season = MushroomSeason(
            monthStart: observation.monthStart,
            monthEnd: observation.monthEnd
        )
        self.plumageId = observation.plumageId
    }
}
