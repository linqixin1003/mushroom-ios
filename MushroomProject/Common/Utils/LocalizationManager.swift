import Foundation
import SwiftUI

// 支持的语言枚举
enum SupportedLanguage: String, CaseIterable {
    case english = "en"
    case japanese = "ja"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case russian = "ru"
    case portuguese = "pt"
    case italian = "it"
    case korean = "ko"
    case turkish = "tr"
    case dutch = "nl"
    case arabic = "ar"
    case thai = "th"
    case swedish = "sv"
    case danish = "da"
    case polish = "pl"
    case finnish = "fi"
    case greek = "el"
    case slovenian = "sl"
    case malay = "ms"
    case traditionalChinese = "zh-Hant"
    case simplifiedChinese = "zh-Hans"
    case catalan = "ca"
    case czech = "cs"
    case indonesian = "id"
    case norwegian = "no"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .japanese: return "日本語"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .russian: return "Русский"
        case .portuguese: return "Português"
        case .italian: return "Italiano"
        case .korean: return "한국어"
        case .turkish: return "Türkçe"
        case .dutch: return "Nederlands"
        case .arabic: return "العربية"
        case .thai: return "ภาษาไทย"
        case .swedish: return "Svenska"
        case .danish: return "Dansk"
        case .polish: return "Polskie"
        case .finnish: return "Suomi"
        case .greek: return "Ελληνικά"
        case .slovenian: return "Slovenčina"
        case .malay: return "Bahasa Melayu"
        case .traditionalChinese: return "繁体中文"
        case .simplifiedChinese: return "简体中文"
        case .catalan: return "Català"
        case .czech: return "čeština"
        case .indonesian: return "Bahasa indonesia"
        case .norwegian: return "Norsk"
        }
    }
    
    var nativeName: String {
        return displayName
    }
}

// 多语言管理器
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    // 添加通知名称
    static let languageChangedNotification = Notification.Name("LanguageChanged")
    
    @Published var currentLanguage: SupportedLanguage = .english {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
            print("LocalizationManager: Language changed to \(currentLanguage.rawValue)")
            
            // 更新应用语言
            updateAppLanguage()
            
            // 发送通知
            NotificationCenter.default.post(name: Self.languageChangedNotification, object: nil)
            
            // 强制刷新所有UI
            // LanguageRefreshHelper.delayedForceRefresh()
        }
    }
    
    // 当前语言的Bundle
    private(set) var currentBundle: Bundle?
    private var bundle: Bundle
    private var languageCode: String = ""
    
    private init() {
        // 默认使用主Bundle
        self.bundle = Bundle.main
        self.currentBundle = Bundle.main
        
        // 从UserDefaults加载保存的语言设置
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = SupportedLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // 如果没有保存的设置，使用系统语言
            self.currentLanguage = getSystemLanguage()
        }
        
        // 初始化时设置应用语言
        updateAppLanguage()
    }
    
    func localizedString(for key: String) -> String {
        // 首先尝试从当前语言的 Resources/Localizations 加载
        let resourcesPath = Bundle.main.path(forResource: "Resources/Localizations/\(currentLanguage.rawValue)", ofType: "lproj")
        if let path = resourcesPath, let resourcesBundle = Bundle(path: path) {
            let localizedString = resourcesBundle.localizedString(forKey: key, value: key, table: nil)
            if localizedString != key {
                return localizedString
            }
        }
        
        // 如果在当前语言找不到，尝试从英语资源加载
        let englishResourcesPath = Bundle.main.path(forResource: "Resources/Localizations/en", ofType: "lproj")
        if let path = englishResourcesPath, let englishBundle = Bundle(path: path) {
            let englishString = englishBundle.localizedString(forKey: key, value: key, table: nil)
            if englishString != key {
                return englishString
            }
        }
        
        // 如果在新位置找不到，尝试从原来的位置加载当前语言
        if let bundle = currentBundle {
            let localizedString = bundle.localizedString(forKey: key, value: key, table: nil)
            if localizedString != key {
                return localizedString
            }
        }
        
        // 如果在当前语言的原位置找不到，尝试从英语原位置加载
        if let englishPath = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let englishBundle = Bundle(path: englishPath) {
            let englishString = englishBundle.localizedString(forKey: key, value: key, table: nil)
            if englishString != key {
                return englishString
            }
        }
        
        // 如果所有尝试都失败，从 Base 语言包加载
        if let basePath = Bundle.main.path(forResource: "Base", ofType: "lproj"),
           let baseBundle = Bundle(path: basePath) {
            let baseString = baseBundle.localizedString(forKey: key, value: key, table: nil)
            if baseString != key {
                return baseString
            }
        }
        
        // 如果还是找不到，返回英语字符串（如果有的话）
        return NSLocalizedString(key, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    private func updateAppLanguage() {
        let languageCode = currentLanguage.rawValue
        
        // 设置应用的语言
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // 尝试加载新位置的语言包
        let resourcesPath = Bundle.main.path(forResource: "Resources/Localizations/\(languageCode)", ofType: "lproj")
        if let path = resourcesPath, let resourcesBundle = Bundle(path: path) {
            self.bundle = resourcesBundle
            self.currentBundle = resourcesBundle
            return
        }
        
        // 回退到原来的位置
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
            self.currentBundle = bundle
        } else {
            // 尝试加载基础语言（不带地区）
            let baseLanguage = languageCode.split(separator: "-").first.map(String.init) ?? languageCode
            if let path = Bundle.main.path(forResource: baseLanguage, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                self.bundle = bundle
                self.currentBundle = bundle
            } else {
                // 如果找不到指定语言，使用Base语言
                if let path = Bundle.main.path(forResource: "Base", ofType: "lproj"),
                   let bundle = Bundle(path: path) {
                    self.bundle = bundle
                    self.currentBundle = bundle
                } else {
                    self.bundle = Bundle.main
                    self.currentBundle = Bundle.main
                }
            }
        }
    }
    
    private func getSystemLanguage() -> SupportedLanguage {
        let systemLanguages = Locale.preferredLanguages
        let systemLanguage = systemLanguages.first ?? "en"
        print("LocalizationManager: System languages are \(systemLanguages)")
        print("LocalizationManager: Primary language is \(systemLanguage)")
        
        // 映射系统语言到支持的语言
        if systemLanguage.hasPrefix("zh-Hans") {
            return .simplifiedChinese
        } else if systemLanguage.hasPrefix("zh-Hant") || systemLanguage.hasPrefix("zh-TW") || systemLanguage.hasPrefix("zh-HK") {
            return .traditionalChinese
        } else if systemLanguage.hasPrefix("zh") {
            return .simplifiedChinese
        } else if systemLanguage.hasPrefix("ar") {
            return .arabic
        } else if systemLanguage.hasPrefix("ru") {
            return .russian
        } else if systemLanguage.hasPrefix("de") {
            return .german
        } else if systemLanguage.hasPrefix("fr") {
            return .french
        } else if systemLanguage.hasPrefix("es") {
            return .spanish
        } else if systemLanguage.hasPrefix("it") {
            return .italian
        } else if systemLanguage.hasPrefix("pt") {
            return .portuguese
        } else if systemLanguage.hasPrefix("nl") {
            return .dutch
        } else if systemLanguage.hasPrefix("ja") {
            return .japanese
        } else if systemLanguage.hasPrefix("ko") {
            return .korean
        } else if systemLanguage.hasPrefix("tr") {
            return .turkish
        } else if systemLanguage.hasPrefix("th") {
            return .thai
        } else if systemLanguage.hasPrefix("sv") {
            return .swedish
        } else if systemLanguage.hasPrefix("da") {
            return .danish
        } else if systemLanguage.hasPrefix("pl") {
            return .polish
        } else if systemLanguage.hasPrefix("fi") {
            return .finnish
        } else if systemLanguage.hasPrefix("el") {
            return .greek
        } else if systemLanguage.hasPrefix("sl") {
            return .slovenian
        } else if systemLanguage.hasPrefix("ms") {
            return .malay
        } else if systemLanguage.hasPrefix("ca") {
            return .catalan
        } else if systemLanguage.hasPrefix("cs") {
            return .czech
        } else if systemLanguage.hasPrefix("id") {
            return .indonesian
        } else if systemLanguage.hasPrefix("no") || systemLanguage.hasPrefix("nb") {
            return .norwegian
        } else {
            return .english // 默认使用英语
        }
    }
    
    // 设置语言的方法
    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language
        self.languageCode = language.rawValue
    }
    
    func setLanguage(languageCode: String) {
        if let language = SupportedLanguage(rawValue: languageCode) {
            setLanguage(language)
        } else {
            self.languageCode = languageCode
            updateAppLanguage()
        }
    }
    
    func getCurrentLanguage() -> String {
        return currentLanguage.rawValue
    }
    
    func resetToSystemLanguage() {
        currentLanguage = getSystemLanguage()
    }
}

// MARK: - String Extension for easy localization

extension String {
    /// 获取本地化字符串的便捷方法
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    /// 获取指定语言的本地化字符串
    func localized(in language: SupportedLanguage) -> String {
        // 使用当前语言的bundle
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: self, table: nil)
        }
        return self
    }
} 