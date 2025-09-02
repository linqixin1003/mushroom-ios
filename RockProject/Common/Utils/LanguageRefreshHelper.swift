import Foundation
import SwiftUI

/// 语言刷新辅助类
/// 用于确保所有UI组件在语言切换时能够正确刷新
class LanguageRefreshHelper {
    static let shared = LanguageRefreshHelper()
    
    private init() {}
    
    /// 强制刷新所有观察LocalizationManager的SwiftUI视图
    static func forceRefreshAllViews() {
        DispatchQueue.main.async {
            // 发送额外的刷新通知
            NotificationCenter.default.post(name: .LanguageForceRefresh, object: nil)
            
            // 强制触发LocalizationManager的objectWillChange
            LocalizationManager.shared.objectWillChange.send()
        }
    }
    
    /// 延迟强制刷新（用于确保语言变化已完全应用）
    static func delayedForceRefresh(delay: TimeInterval = 0.1) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            forceRefreshAllViews()
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let LanguageForceRefresh = Notification.Name("LanguageForceRefresh")
}

// MARK: - SwiftUI View Extension for Language Refresh
extension View {
    /// 为SwiftUI视图添加语言变化监听
    func onLanguageChange(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .LanguageForceRefresh)) { _ in
            action()
        }
    }
} 