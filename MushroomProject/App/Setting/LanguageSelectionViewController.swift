import UIKit
import SwiftUI

// 导入LanguageTranslations
import Foundation

/// 这个结构体包含所有26种语言的"设置语言"和"取消"按钮的翻译
/// 用于在本地化文件未加载时提供默认翻译
struct LanguageTranslations {
    
    /// 获取指定语言的"设置语言"翻译
    static func settingsSetLanguage(for language: SupportedLanguage) -> String {
        switch language {
        case .english: return "Language"
        case .simplifiedChinese: return "语言"
        case .traditionalChinese: return "語言"
        case .japanese: return "言語"
        case .spanish: return "Idioma"
        case .french: return "Langue"
        case .german: return "Sprache"
        case .russian: return "Язык"
        case .portuguese: return "Idioma"
        case .italian: return "Lingua"
        case .korean: return "언어"
        case .turkish: return "Dil"
        case .dutch: return "Taal"
        case .arabic: return "اللغة"
        case .thai: return "ภาษา"
        case .swedish: return "Språk"
        case .danish: return "Sprog"
        case .polish: return "Język"
        case .finnish: return "Kieli"
        case .greek: return "Γλώσσα"
        case .slovenian: return "Jezik"
        case .malay: return "Bahasa"
        case .catalan: return "Idioma"
        case .czech: return "Jazyk"
        case .indonesian: return "Bahasa"
        case .norwegian: return "Språk"
        }
    }
    
    /// 获取指定语言的"取消"按钮翻译
    static func textCancel(for language: SupportedLanguage) -> String {
        switch language {
        case .english: return "Cancel"
        case .simplifiedChinese: return "取消"
        case .traditionalChinese: return "取消"
        case .japanese: return "キャンセル"
        case .spanish: return "Cancelar"
        case .french: return "Annuler"
        case .german: return "Abbrechen"
        case .russian: return "Отмена"
        case .portuguese: return "Cancelar"
        case .italian: return "Annulla"
        case .korean: return "취소"
        case .turkish: return "İptal"
        case .dutch: return "Annuleren"
        case .arabic: return "إلغاء"
        case .thai: return "ยกเลิก"
        case .swedish: return "Avbryt"
        case .danish: return "Annuller"
        case .polish: return "Anuluj"
        case .finnish: return "Peruuta"
        case .greek: return "Ακύρωση"
        case .slovenian: return "Prekliči"
        case .malay: return "Batal"
        case .catalan: return "Cancel·lar"
        case .czech: return "Zrušit"
        case .indonesian: return "Batal"
        case .norwegian: return "Avbryt"
        }
    }
}

class LanguageSelectionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear

        let languageSelectionView = LanguageSelectionView { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        let hostingController = UIHostingController(rootView: languageSelectionView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - SwiftUI Language Selection View

struct LanguageSelectionView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var settingsLanguageTitle = ""
    @State private var cancelText = ""
    let onDismiss: () -> Void
    
    // 图片中显示的语言顺序
    private let allLanguages: [SupportedLanguage] = [
        .english,
        .japanese,
        .spanish,
        .french,
        .german,
        .russian,
        .portuguese,
        .italian,
        .korean,
        .dutch,
        .arabic,
        .traditionalChinese,
        .simplifiedChinese
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // 语言列表卡片
            VStack(spacing: 0) {
                // 标题
                Text(settingsLanguageTitle)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.vertical, 16)
                
                Divider()
                
                // 语言列表
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(allLanguages, id: \.rawValue) { language in
                            LanguageRowView(
                                language: language,
                                isSelected: language == localizationManager.currentLanguage
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectLanguage(language)
                            }
                            
                            if language != allLanguages.last {
                                Divider()
                            }
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            
            // 空白间隔
            Spacer().frame(height: 8)
            
            // 取消按钮卡片 - 与语言列表分开
            Button(action: {
                onDismiss()
            }) {
                Text(cancelText)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: 0x37C361))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
        }
        .onAppear {
            // 首先使用默认翻译
            updateTexts(language: localizationManager.currentLanguage)
            
            // 然后尝试加载本地化字符串
            if let path = Bundle.main.path(forResource: localizationManager.currentLanguage.rawValue, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                        let localizedTitle = bundle.localizedString(forKey: "settings_set_language", value: "settings_set_language", table: nil)
        let localizedCancel = bundle.localizedString(forKey: "text_cancel", value: "text_cancel", table: nil)
                
                // 如果本地化字符串不是键名本身，则使用它
                if localizedTitle != "settings_set_language" {
                    settingsLanguageTitle = localizedTitle
                }
                
                if localizedCancel != "text_cancel" {
                    cancelText = localizedCancel
                }
            }
        }
    }
    
    private func updateTexts(language: SupportedLanguage) {
        // 使用默认翻译
        settingsLanguageTitle = LanguageTranslations.settingsSetLanguage(for: language)
        cancelText = LanguageTranslations.textCancel(for: language)
    }
    
    private func selectLanguage(_ language: SupportedLanguage) {
        localizationManager.setLanguage(language)
        
        // 更新本地化文本
        updateTexts(language: language)
        
        // 尝试加载本地化字符串
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let localizedTitle = bundle.localizedString(forKey: "settings_set_language", value: "settings_set_language", table: nil)
            let localizedCancel = bundle.localizedString(forKey: "text_cancel", value: "text_cancel", table: nil)
            
            // 如果本地化字符串不是键名本身，则使用它
            if localizedTitle != "settings_set_language" {
                settingsLanguageTitle = localizedTitle
            }
            
            if localizedCancel != "text_cancel" {
                cancelText = localizedCancel
            }
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}

// MARK: - Language Row View

struct LanguageRowView: View {
    let language: SupportedLanguage
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Text(language.displayName)
                .font(.system(size: 16))
                .foregroundColor(isSelected ? Color(hex: 0x37C361) : .primary)
            Spacer()
        }
        .padding(.vertical, 16)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Preview

struct LanguageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSelectionView {
            // Preview dismiss action
        }
    }
} 
