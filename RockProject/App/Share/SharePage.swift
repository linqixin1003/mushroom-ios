//
//  ShareView.swift
//  RockProject
//
//  Created by conalin on 2025/6/20.
//

import SwiftUI
import PhotosUI
import UIKit

struct ShareView: View {
    @ObservedObject var viewModel: ShareViewModel
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    @State private var cardSize: CGSize = CGSize(width: 262 * 1.2, height: 342 * 1.2)
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.shareOpen, closeEventName: EventName.shareClose)
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TopBar(onBack: onBack)
            ZStack {
                Color.black.ignoresSafeArea()
                if viewModel.isLoading {
                    ProgressView()
                } else if let image = viewModel.image {
                    GeometryReader { proxy in
                        ShareCard(image: image, name: viewModel.name, isSound: false)
                            .background(
                                Color.clear
                                    .onAppear {
                                        self.cardSize = proxy.size
                                    }
                            )
                    }
                    .frame(width: cardSize.width, height: cardSize.height)
                } else {
                    Text(Language.share_image_load_failed).foregroundColor(.red)
                }
            }
            BottomBar(
                onDownLoad: {
                    FireBaseEvent.send(eventName: EventName.shareDownClick)
                    let card = ShareCard(image: viewModel.image ?? UIImage(), name: viewModel.name, isSound: false)
                    let image = card.snapshotWithIntrinsicSize()
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    viewModel.alertTitle = Language.share_success
                    viewModel.alertMessage = Language.share_card_saved
                    viewModel.showingAlert = true
                },
                onShare: {
                    FireBaseEvent.send(eventName: EventName.shareShareClick)
                    let card = ShareCard(image: viewModel.image ?? UIImage(), name: viewModel.name, isSound: false)
                    self.shareImage = card.snapshotWithIntrinsicSize()
                }
            )
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard)
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text(Language.text_ok)))
        }
        .sheet(item: $shareImage) { image in
            ActivityShareSheet(activityItems: [image])
        }
    }
}

// 用于呈现系统分享页的辅助视图
private struct ActivityShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // 监听分享完成事件
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                // 分享成功，触发求好评检查
                AppReviewManager.shared.checkAndRequestReviewAfterShare()
                // 使用现有的事件名称，移除不存在的参数
                FireBaseEvent.send(eventName: EventName.shareShareClick, params: [
                    "completed": "true"
                ])
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct ShareCard: View {
    let image: UIImage
    let name: String
    let isSound: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("icon_app")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                Text(Language.about_app_name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex:0xB98245))
                Spacer()
            }
            .padding(.horizontal, 9)
            .frame(height: 36)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 257 * 1.2, height: 257 * 1.2)
                .padding(.top, 10)
            
            Spacer(minLength: 0)
            
            Text(name)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.vertical, 15)
                .padding(.horizontal, 9)
        }
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(8)
    }
}

// 顶部导航栏视图
private struct TopBar: View {
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    FireBaseEvent.send(eventName: EventName.shareCloseClick)
                    onBack()
                }) {
                    Image("icon_back_24")
                }
                
                Text(Language.share_title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appText)
                    .padding(.leading, 16)
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding(.horizontal)
            .frame(height: 44)
            
            Divider()
        }
    }
}

// 底部操作栏视图
private struct BottomBar: View {
    var onDownLoad: () -> Void
    var onShare: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                Spacer()
                BottomActionButton(
                    iconName: "icon_download",
                    text: Language.share_download,
                    action: onDownLoad
                )
                Spacer()
                BottomActionButton(
                    iconName: "icon_share_24_2",
                    text: Language.share_share,
                    action: onShare
                )
                Spacer()
            }
            .frame(height: 88)
        }
    }
}

// 底部操作按钮的封装
private struct BottomActionButton: View {
    let iconName: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(iconName)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 24, height: 24)
                
                Text(text)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}

extension View {
    func snapshotWithIntrinsicSize() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view!

        // 让内容自动撑开
        let targetSize = view.intrinsicContentSize
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .white
        view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension UIImage: Identifiable {
    public var id: String { UUID().uuidString }
}



