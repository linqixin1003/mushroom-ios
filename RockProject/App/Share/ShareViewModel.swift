//
//  ShareViewModel.swift
//  RockProject
//
//  Created by conalin on 2025/6/26.
//
// 这是一个可观察的 ViewModel，用于驱动视图

import SwiftUI
import PhotosUI
import UIKit

// MARK: - 分享数据模型
struct ShareData {
    let imageUrl: String?
    let text: String
    
    init(imageUrl: String? = nil, text: String) {
        self.imageUrl = imageUrl
        self.text = text
    }
}

class ShareViewModel: ObservableObject {
    @Published var url: String?
    @Published var name: String
    
    @Published var image: UIImage?
    @Published var isLoading = true
    
    // For alert feedback
    @Published var showingAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    init(url: String?, name: String) {
        self.url = url
        self.name = name
        print("Initializing share data: URL=\(url ?? ""), Name=\(name)")
        fetchImage()
    }
    
    init(image: UIImage?, name: String) {
        self.image = image
        self.name = name
        self.isLoading = false
    }
    
    private func fetchImage() {
        guard let imageURL = URL(string: url ?? "") else {
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = data, let downloadedImage = UIImage(data: data) {
                    self.image = downloadedImage
                } else {
                    print("Image download failed: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }.resume()
    }
    
    func saveToPhotoAlbum() {
        guard let imageToSave = image else {
            self.alertTitle = Language.share_error
            self.alertMessage = Language.share_image_not_available
            self.showingAlert = true
            return
        }
        
        // 请求相册访问权限
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
                    self.alertTitle = Language.share_success
                    self.alertMessage = Language.share_image_saved
                    self.showingAlert = true
                } else {
                    self.alertTitle = Language.share_permission_denied
                    self.alertMessage = Language.share_permission_message
                    self.showingAlert = true
                }
            }
        }
    }
    
    // MARK: - 通用分享方法
    
    /// 通用分享方法，支持图片URL和文本分享
    /// - Parameters:
    ///   - imageUrl: 图片的URL字符串
    ///   - text: 要分享的文本内容
    ///   - completion: 完成回调，返回分享内容数组或错误信息
    static func shareContent(imageUrl: String?, text: String, completion: @escaping (Result<[Any], ShareError>) -> Void) {
        var shareItems: [Any] = []
        
        // 添加文本内容
        if !text.isEmpty {
            shareItems.append(text)
        }
        
        // 如果有图片URL，下载并添加图片
        if let urlString = imageUrl, !urlString.isEmpty, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        shareItems.append(image)
                        completion(.success(shareItems))
                    } else {
                        // 图片下载失败，只分享文本
                        let errorMessage = error?.localizedDescription ?? "Image download failed"
                        print("Image download failed: \(errorMessage)")
                        completion(.success(shareItems)) // 仍然返回文本内容
                    }
                }
            }.resume()
        } else {
            // 没有图片URL，直接返回文本内容
            DispatchQueue.main.async {
                completion(.success(shareItems))
            }
        }
    }
    
    /// 便捷的分享方法，展示自定义分享界面（ShareView）
    /// - Parameters:
    ///   - imageUrl: 图片的URL字符串
    ///   - text: 要分享的文本内容
    ///   - viewController: 用于展示分享界面的视图控制器
    static func presentShare(imageUrl: String?, text: String, from viewController: UIViewController) {
        presentShare(imageUrl: imageUrl, text: text, isSound: false, from: viewController)
    }
    
    /// 便捷的分享方法，展示自定义分享界面（ShareView），支持声音分享
    /// - Parameters:
    ///   - imageUrl: 图片的URL字符串
    ///   - text: 要分享的文本内容
    ///   - isSound: 是否为声音分享
    ///   - viewController: 用于展示分享界面的视图控制器
    static func presentShare(imageUrl: String?, text: String, isSound: Bool, from viewController: UIViewController) {
        // 检查是否有内容可以分享
        if text.isEmpty && (imageUrl?.isEmpty ?? true) {
            showShareFailureAlert(message: Language.share_no_content, from: viewController)
            return
        }
        
        // 创建 ShareViewModel
        let shareViewModel = ShareViewModel(
            url: imageUrl,
            name: text
        )
        
        // 创建 ShareView
        let shareView = ShareView(
            viewModel: shareViewModel,
            onBack: {
                // 关闭分享界面
                viewController.dismiss(animated: true)
            }
        )
        
        // 包装到 UIHostingController
        let hostingController = UIHostingController(rootView: shareView)
        
        // 设置为全屏模式
        hostingController.modalPresentationStyle = .fullScreen
        
        // 展示分享界面
        viewController.present(hostingController, animated: true, completion: nil)
    }
    
    /// 显示分享失败的提示
    /// - Parameters:
    ///   - message: 错误消息
    ///   - viewController: 用于展示提示的视图控制器
    private static func showShareFailureAlert(message: String, from viewController: UIViewController) {
        let alert = UIAlertController(
            title: Language.share_failed,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: Language.share_ok, style: .default))
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
    
    /// 便捷的分享方法，直接使用ShareData对象展示自定义分享界面
    /// - Parameters:
    ///   - shareData: 分享数据对象
    ///   - viewController: 用于展示分享界面的视图控制器
    static func presentShare(shareData: ShareData, from viewController: UIViewController) {
        presentShare(
            imageUrl: shareData.imageUrl,
            text: shareData.text,
            isSound: false,
            from: viewController
        )
    }
}

// MARK: - 分享错误类型
enum ShareError: Error, LocalizedError {
    case invalidImageUrl
    case imageDownloadFailed
    case noContentToShare
    
    var errorDescription: String? {
        switch self {
        case .invalidImageUrl:
            return Language.share_error_invalid_url
        case .imageDownloadFailed:
            return Language.share_error_download_failed
        case .noContentToShare:
            return Language.share_error_no_content
        }
    }
}
