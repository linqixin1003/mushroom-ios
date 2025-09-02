import UIKit

class PersistUtil {
    
    static var hasAgreeAgreement: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "has_agree_agreement")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "has_agree_agreement")
        }
    }
    
    static var deviceId: String? {
        get {
            return UserDefaults.standard.string(forKey: "device_id")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "device_id")
        }
    }
    
    static var userId: String? {
        get {
            return UserDefaults.standard.string(forKey: "user_id")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "user_id")
        }
    }
    
    static var isVip: Bool {
        get {
            return LocalPurchaseManager.checkVIPStatus
        }
        set {
            // 不再直接设置，由 LocalPurchaseManager 管理
        }
    }
    
    static var user: User? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "user") else { return nil }
            return try? JSONDecoder().decode(User.self, from: data)
        }
        set {
            if let user = newValue,
               let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: "user")
            } else {
                UserDefaults.standard.removeObject(forKey: "user")
            }
        }
    }
    
    static var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "access_token")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "access_token")  
        }  
    }
    
    static var chatMessages: String? {
        get {
            return UserDefaults.standard.string(forKey: "chat_messages")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "chat_messages")
        }
    }
    
    static var autoSaveImage: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "auto_save_image")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "auto_save_image")
        }
    }
    
    // MARK: - Convert Page Management
    
    /// 本次启动是否已经弹出过转化页（内存变量，不持久化）
    private static var _hasShownConvertPageThisLaunch: Bool = false
    
    /// 检查本次启动是否已经弹出过转化页
    static var hasShownConvertPageThisLaunch: Bool {
        return _hasShownConvertPageThisLaunch
    }
    
    /// 标记本次启动已经弹出过转化页
    static func markConvertPageShownThisLaunch() {
        _hasShownConvertPageThisLaunch = true
    }
    
    /// 重置本次启动弹出标记（app重启时调用）
    static func resetLaunchFlags() {
        _hasShownConvertPageThisLaunch = false
    }
    
    /// 获取今天转化页弹出次数
    static var todayConvertPageShowCount: Int {
        get {
            let today = dateFormatter.string(from: Date())
            let key = "convert_page_show_count_\(today)"
            return UserDefaults.standard.integer(forKey: key)
        }
        set {
            let today = dateFormatter.string(from: Date())
            let key = "convert_page_show_count_\(today)"
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
    
    /// 检查今天是否可以弹出转化页（每天最多2次，且本次启动未弹出过）
    static var canShowConvertPageToday: Bool {
        return todayConvertPageShowCount < 2 && !hasShownConvertPageThisLaunch
    }
    
    /// 增加今天转化页弹出次数并标记本次启动已弹出
    static func incrementTodayConvertPageShowCount() {
        todayConvertPageShowCount += 1
        markConvertPageShownThisLaunch()
    }
    
    /// 清理旧的转化页弹出记录（保留最近7天）
    static func cleanupOldConvertPageRecords() {
        let calendar = Calendar.current
        let now = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        for i in 0..<30 { // 检查过去30天的记录
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            if date < sevenDaysAgo {
                let dateString = dateFormatter.string(from: date)
                let key = "convert_page_show_count_\(dateString)"
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MARK: - App Review Management
    
    /// 获取识别成功次数
    static var identificationSuccessCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "identification_success_count")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "identification_success_count")
        }
    }
    
    /// 增加识别成功次数
    static func incrementIdentificationSuccessCount() {
        identificationSuccessCount += 1
    }
    
    /// 获取分享完成次数
    static var shareCompletedCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "share_completed_count")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "share_completed_count")
        }
    }
    
    /// 增加分享完成次数
    static func incrementShareCompletedCount() {
        shareCompletedCount += 1
    }
    
    /// 获取上次弹出求好评的时间
    static var lastReviewRequestDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "last_review_request_date") as? Date
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "last_review_request_date")
        }
    }
    
    /// 检查是否可以弹出求好评（3个月内只能弹出一次）
    static var canShowReviewRequest: Bool {
        guard let lastDate = lastReviewRequestDate else {
            return true // 从未弹出过，可以弹出
        }
        
        let calendar = Calendar.current
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        return lastDate < threeMonthsAgo
    }
    
    /// 标记已弹出求好评
    static func markReviewRequestShown() {
        lastReviewRequestDate = Date()
    }
    
    /// 重置求好评相关数据（用于测试）
    static func resetReviewData() {
        identificationSuccessCount = 0
        shareCompletedCount = 0
        lastReviewRequestDate = nil
    }
    
    static func clearAllData() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
}
