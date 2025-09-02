//
//  AppReviewManager.swift
//  RockProject
//
//  Created by AI Assistant on 2025/01/02.
//

import Foundation
import StoreKit
import UIKit

/// App Store 求好评管理器
class AppReviewManager {
    
    /// 单例实例
    static let shared = AppReviewManager()
    
    private init() {}
    
    // MARK: - 触发条件检查
    
    /// 检查识别成功后是否需要弹出求好评
    func checkAndRequestReviewAfterIdentification() {
        // 检查基本条件：3个月内未弹出过
        guard PersistUtil.canShowReviewRequest else {
            debugPrint("[AppReview] Cannot show review: within 3 months limit")
            return
        }
        
        // 增加识别次数
        PersistUtil.incrementIdentificationSuccessCount()
        
        // 检查识别次数是否达到2次
        if PersistUtil.identificationSuccessCount >= 2 {
            showReviewRequest(trigger: "identification_success")
        } else {
            debugPrint("[AppReview] Identification count: \(PersistUtil.identificationSuccessCount), need 2 to trigger")
        }
    }
    
    /// 检查分享完成后是否需要弹出求好评
    func checkAndRequestReviewAfterShare() {
        // 检查基本条件：3个月内未弹出过
        guard PersistUtil.canShowReviewRequest else {
            debugPrint("[AppReview] Cannot show review: within 3 months limit")
            return
        }
        
        // 增加分享次数
        PersistUtil.incrementShareCompletedCount()
        
        // 分享完成后立即弹出求好评
        showReviewRequest(trigger: "share_completed")
    }
    
    // MARK: - 弹出求好评
    
    /// 弹出求好评弹框
    /// - Parameter trigger: 触发原因，用于埋点统计
    private func showReviewRequest(trigger: String) {
        // 发送埋点事件 - 使用现有的事件名称
        FireBaseEvent.send(eventName: EventName.splashOpen, params: [
            "review_trigger": trigger,
            "identification_count": String(PersistUtil.identificationSuccessCount),
            "share_count": String(PersistUtil.shareCompletedCount)
        ])
        
        // 标记已弹出
        PersistUtil.markReviewRequestShown()
        
        // 弹出系统求好评弹框
        DispatchQueue.main.async {
            self.presentReviewRequest()
        }
        
        debugPrint("[AppReview] Review request shown - trigger: \(trigger)")
    }
    
    /// 弹出系统求好评弹框
    private func presentReviewRequest() {
        if #available(iOS 14.0, *) {
            // iOS 14+ 使用新的 API
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        } else {
            // iOS 13 及以下使用旧的 API
            SKStoreReviewController.requestReview()
        }
    }
    
    // MARK: - 手动跳转 App Store
    
    /// 手动跳转到 App Store 评分页面
    static func openAppStoreReview() {
        guard let url = Config.shareAppUrl,
              UIApplication.shared.canOpenURL(url) else {
            debugPrint("[AppReview] Cannot open App Store URL")
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                // 使用现有的事件名称
                FireBaseEvent.send(eventName: EventName.settingToRateClick)
                debugPrint("[AppReview] Manual App Store review opened")
            } else {
                debugPrint("[AppReview] Failed to open App Store review")
            }
        }
    }
    
    // MARK: - 调试方法
    
    /// 强制弹出求好评（用于测试）
    func forceShowReview(trigger: String = "debug") {
        showReviewRequest(trigger: trigger)
    }
    
    /// 获取当前状态信息（用于调试）
    func getDebugInfo() -> String {
        let canShow = PersistUtil.canShowReviewRequest
        let identCount = PersistUtil.identificationSuccessCount
        let shareCount = PersistUtil.shareCompletedCount
        let lastDate = PersistUtil.lastReviewRequestDate?.description ?? "Never"
        
        return """
        AppReview Debug Info:
        - Can show review: \(canShow)
        - Identification count: \(identCount)
        - Share count: \(shareCount)
        - Last review date: \(lastDate)
        """
    }
} 
