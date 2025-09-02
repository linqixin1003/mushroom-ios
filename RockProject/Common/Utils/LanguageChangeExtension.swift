import SwiftUI
import Combine

extension View {
    /// 监听语言变化通知，在通知触发时执行指定动作
    /// - Parameter action: 在语言变化后需要执行的闭包
    /// - Returns: 关联的 View
    func onLanguageChange(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: LocalizationManager.languageChangedNotification)) { _ in
            action()
        }
    }
} 