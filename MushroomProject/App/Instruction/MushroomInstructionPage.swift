//
//  MushroomInstructionPage.swift
//  RockProject
//
//  Created by conalin on 2025/6/7.
//

import SwiftUI

struct MushroomInstruction: Identifiable {
    let id = UUID()
    let title: String
    let instructionbar: String
}

struct MushroomInstructionItemView: View {
    let item: MushroomInstruction

    var body: some View {
        VStack(alignment: .leading, spacing: 8.rpx) {
            Text(item.title)
                .font(.subheadline)
                .foregroundColor(.appTextLight)
                .padding(.horizontal)

            HStack(spacing: 16) {
                ZStack(alignment: .center) {
                    Image(item.instructionbar)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                    Image("instruct_row")
                        .resizable()
                        .frame(width: 62, height: 22)
                }
            }
            .padding(.horizontal, 6.rpx)
            
        }
    }
}

struct MushroomInstructionPage: View {
    
    let onBackClick: () -> Void
    let onIdentifyClick: () -> Void
    
    let instructions: [MushroomInstruction] = [
        MushroomInstruction(title: Language.instruction_step_1, instructionbar: "instruct_banner1"),
        MushroomInstruction(title: Language.instruction_step_2, instructionbar: "instruct_banner2"),
        MushroomInstruction(title: Language.instruction_step_3, instructionbar: "instruct_banner3"),
        MushroomInstruction(title: Language.instruction_step_4, instructionbar: "instruct_banner4"),
        MushroomInstruction(title: Language.instruction_step_5, instructionbar: "instruct_banner5")
    ]
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.instructionsOpen, closeEventName: EventName.instructionsClose)
    var body: some View {
        AppPage(
            title: Language.instruction_page_title,
            leftButtonConfig: .init(imageName: "icon_back_24", onClick: {
                self.onBackClick()
            }),
            rightButtonConfig: nil
        ) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .center, spacing: 16.rpx) {
                        // 说明文字
                        Text(Language.instruction_good_image_quality)
                            .font(.subheadline)
                            .font(.regular(16.rpx))
                            .foregroundColor(.appText)
                            .padding(.top, 27.rpx)
                            .padding(.bottom, 8.rpx)
                            .padding(.horizontal, 10.rpx)
                        
                        // 替换原有 ForEach 部分
                        ForEach(instructions) { item in
                            MushroomInstructionItemView(item: item)
                        }
                        Spacer()
                            .frame(height: 1.rpx)
                    }
                    .background(.white)
                    .clipShape(RoundedCorner(radius: 6.rpx))
                    .padding(.horizontal, 10.rpx)
                    .padding(.vertical, 12.rpx)
                }
                VStack(spacing: 0) {
                    Button {
                        self.onIdentifyClick()
                    } label: {
                        HStack(alignment: .center, spacing: 16.rpx) {
                            Image("instruct_identify_24")
                                
                            Text(Language.instruction_identify)
                                .font(.regular(20.rpx))
                                .foregroundColor(.white)
                                
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48.rpx)
                        .background(Color.primary)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 18.rpx)
                    .padding(.top, 17.rpx)
                    .padding(.bottom, SafeBottom + 13.rpx)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .background(.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.3))
                        .position(x: UIScreen.main.bounds.width / 2, y: 0)
                )
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct MushroomInstructionPage_Previews: PreviewProvider {
    static var previews: some View {
        MushroomInstructionPage(
            onBackClick: {},
            onIdentifyClick: {}
        )
    }
}
