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
    let stone: Stone
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
            title: self.stone.name,
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
                            stone: stone,
                            actionModel: actionModel) { url, image in
                                self.compareImageUrl = url
                            }
                        StoneSummaryView(
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
                                StoneImagesSectionView(
                                    imageUrls: stone.images,
                                    onMoreClick: stone.images.count <= 2 ? nil : {
                                        FireBaseEvent.send(eventName: EventName.resultImageMoreClick, params: [EventParam.uid: self.stone.id])
                                        self.actionModel.onViewMoreImagesClick.send(stone.images)
                                        self.showingMoreImagesPage = true
                                    }) { position, imageUrl in
                                        FireBaseEvent.send(eventName: EventName.resultViewImageClick, params: [EventParam.uid: self.stone.id, EventParam.index: String(position)])
                                        self.actionModel.onImageClick.send((position, imageUrl))
                                    }
                            }
                            
                            // 化学属性区域
                            StoneChemicalPropertiesSectionView(stone: stone)
                            
                            // 物理属性区域
                            StonePhysicalPropertiesSectionView(stone: stone)
                            
                            // 护理说明区域
                            if !(stone.storage ?? "").isEmpty || !(stone.cleaningTips ?? "").isEmpty {
                                StoneCareInstructionsSectionView(stone: stone)
                            }
                            
                            // 价格信息区域
                            if stone.pricePerCaratFrom != nil || stone.pricePerPoundFrom != nil {
                                StonePriceSectionView(stone: stone)
                            }
                            
                            // 形而上学属性区域
                            if (stone.showMetaphysical ?? false) {
                                StoneMetaphysicalSectionView(stone: stone)
                            }
                            
                            // FAQ区域
                            if stone.faqs?.isEmpty == false {
                                StoneFAQSectionView(stone: stone)
                            }
                            
                            // 用途和健康信息区域
                            if !(stone.usage ?? "").isEmpty || (stone.healthRisks?.isEmpty == false) {
                                StoneUsageSectionView(stone: stone)
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
                        FireBaseEvent.send(eventName: EventName.resultRetakeClick, params: [EventParam.uid: self.stone.id, EventParam.index: "1"])
                        self.actionModel.bottomActionClick.send(type)
                    case .addWish:
                        FireBaseEvent.send(eventName: "result_add_wish_click", params: [EventParam.uid: self.stone.id])
                        self.actionModel.bottomActionClick.send(type)
                    case .save:
                        FireBaseEvent.send(eventName: EventName.resultSaveClick, params: [EventParam.uid: self.stone.id])
                        self.actionModel.bottomActionClick.send(type)
                    case .share:
                        FireBaseEvent.send(eventName: EventName.resultShareClick, params: [EventParam.uid: self.stone.id])
                        self.handleShareAction()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingMoreImagesPage) {
            MoreImagePage(imageUrls: stone.images, onCloseClick: {
                self.showingMoreImagesPage = false
            }, onImageClick: { index in
                self.actionModel.onImageClick.send((index, stone.images))
            })
        }
        .fullScreenCover(isPresented: $showingSharePage) {
            ShareView(
                viewModel: ShareViewModel(
                    image: capturedImage,
                    name: stone.name
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

extension StoneObservation {
    init(from observation: Observation) {
        self.id = observation.id
        self.colors = StoneColors(
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
        self.environment = StoneEnvironment(
            feeder: observation.feeder,
            fence: observation.fence,
            ground: observation.ground,
            trees: observation.trees,
            water: observation.water
        )
        self.behavior = StoneBehavior(
            flying: observation.flying
        )
        self.size = StoneSize(
            size1: observation.size1,
            size2: observation.size2,
            size3: observation.size3,
            size4: observation.size4,
            size5: observation.size5,
            size6: observation.size6,
            size7: observation.size7
        )
        self.season = StoneSeason(
            monthStart: observation.monthStart,
            monthEnd: observation.monthEnd
        )
        self.plumageId = observation.plumageId
    }
}
