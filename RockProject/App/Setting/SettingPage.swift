import SwiftUI
import Combine
struct SettingActionModel {
    let backClick = PassthroughSubject<Void, Never>()
    let onToVip = PassthroughSubject<Void, Never>()
    let onBack = PassthroughSubject<Void, Never>()
    let onNavigateToLanguage = PassthroughSubject<Void, Never>()
    let onNavigateToPrivacyPolicy = PassthroughSubject<Void, Never>()
    let onNavigateToTerms = PassthroughSubject<Void, Never>()
    let onSuggestion = PassthroughSubject<Void, Never>()
    let onNavigateToAbout = PassthroughSubject<Void, Never>()
    let onNavigateToShare = PassthroughSubject<Void, Never>()
    let onNavigateToRate = PassthroughSubject<Void, Never>()
    let onNavigateToAccountManagement = PassthroughSubject<Void, Never>()
    let onSandboxTest = PassthroughSubject<Void, Never>()
}
struct SettingScreen: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    let actionModel:SettingActionModel
    @State var autoSaveImage:Bool = PersistUtil.autoSaveImage
    var body: some View {
        AppPage(title: Language.settings_title,
                leftButtonConfig: .init(imageName: "icon_back_24", onClick: {
                    self.actionModel.backClick.send()
                }),
                rightButtonConfig: nil
        ) {
            ScrollView {
                VStack(spacing: 12.rpx) {
                    if !PersistUtil.isVip{
                        SettingsSection {
                            SettingsItem(
                                icon: Image("icon_setting_premium"),
                                title: Language.settings_premium_service,
                                onClick: {self.actionModel.onToVip.send()}
                            )
                        }
                    }
                    // Basic Settings Section
                    SettingsSection {
                        VStack(spacing:0) {
                            Button(action: {
                                self.autoSaveImage = !self.autoSaveImage
                                PersistUtil.autoSaveImage = self.autoSaveImage
                            }) {
                                HStack(alignment: .center) {
                                    Image("icon_auto_save_image")
                                        .renderingMode(.template)  // 先设置渲染模式
                                        .resizable()              // 然后是图片相关属性
                                        .frame(width: 24.rpx, height: 24.rpx)
                                        .foregroundColor(.appText)  // 最后是	等视图属性
                                    Text(Language.settings_autosave_photos)
                                       .font(.system(size: 14.rpx))
                                       .lineLimit(1)
                                       .truncationMode(.tail)
                                       .foregroundColor(.appText)
                                       .frame(maxWidth: .infinity, alignment: .leading)
                                    Image(autoSaveImage ? "icon_switch" : "icon_switch_unselected")
                                       .resizable()
                                       .frame(width: 51.rpx, height: 31.rpx)
                                }
                               .frame(height: 60.rpx)
                               .padding(.horizontal, 16.rpx)
                            }
                        }
                    }
                    // About App Section
                    SettingsSection {
                        VStack(spacing:0) {                            
                            SettingsItem(
                                icon: Image("icon_language"),
                                title: Language.settings_set_language,
                                onClick: {self.actionModel.onNavigateToLanguage.send()}
                            )
                            
                            Divider().padding(.horizontal, 25.rpx)
                            SettingsItem(
                                icon: Image("icon_suggest"),
                                title: Language.settings_suggestion,
                                onClick: {self.actionModel.onSuggestion.send()}
                            )
                            Divider().padding(.horizontal, 25.rpx)
                            SettingsItem(
                                icon: Image("icon_about_us"),
                                title: Language.settings_app_info,
                                onClick: {self.actionModel.onNavigateToAbout.send()}
                            )
                            Divider().padding(.horizontal, 25.rpx)
                            SettingsItem(
                                icon: Image("icon_share_setting"),
                                title: Language.settings_tell_friends,
                                onClick: {self.actionModel.onNavigateToShare.send()}
                            )
                            #if DEBUG
                            Divider().padding(.horizontal, 25.rpx)
                            SettingsItem(
                                icon: Image("icon_setting_vip"),
                                title: "🧪 Sandbox Test",
                                onClick: {self.actionModel.onSandboxTest.send()}
                            )
                            #endif
                        }
                    }
                    // Legal Section
                    SettingsSection {
                        VStack(spacing:0) {
                            SettingsItem(
                                icon: Image("icon_privacy"),
                                title: Language.settings_privacy_policy,
                                onClick: {self.actionModel.onNavigateToPrivacyPolicy.send()}
                            )
                            Divider().padding(.horizontal, 25.rpx)
                            SettingsItem(
                                icon: Image("icon_term_service"),
                                title: Language.settings_terms_of_use,
                                onClick: {self.actionModel.onNavigateToTerms.send()}
                            )
                            Divider().padding(.horizontal, 25.rpx)
                            SettingsItem(
                                icon: Image("icon_account"),
                                title: Language.settings_manage_account,
                                onClick: {self.actionModel.onNavigateToAccountManagement.send()}
                            )
                        }
                    }
                }
               .padding(.horizontal, 16.rpx)
               .padding(.top, 14.rpx)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
       .background(Color(UIColor.systemBackground))
       .cornerRadius(12.rpx)
    }
}

struct SettingsItem: View {
    let icon: Image
    let title: String
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                icon
                    .renderingMode(.template)  // 先设置渲染模式
                    .resizable()              // 然后是图片相关属性
                    .frame(width: 24.rpx, height: 24.rpx)
                    .foregroundColor(.appText)  // 最后是颜色等视图属性
                   
                Text(title)
                   .font(.system(size: 14.rpx))
                   .foregroundColor(.appText)
                   .frame(maxWidth: .infinity, alignment: .leading)
                Image("icon_arrow_right")
                   .resizable()
                   .frame(width: 24.rpx, height: 24.rpx)
            }
           .padding(.vertical, 16.rpx)
           .padding(.horizontal, 16.rpx)
        }
    }
}
