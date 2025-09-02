import SwiftUI
import Combine
import StoreKit
import UIKit

class SettingViewController: BaseHostingViewController<SettingScreen> {
    private var cancellables = Set<AnyCancellable>()
    private let actionModle = SettingActionModel()
    private let sendOpenCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.settingOpen, closeEventName: EventName.settingClose)
    
    init() {
        super.init(rootView:SettingScreen(actionModel: self.actionModle), title: "Settings")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setActions()
        
        // 监听语言变化通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: LocalizationManager.languageChangedNotification,
            object: nil
        )
    }
    
    @objc private func languageChanged() {
        // 更新 rootView
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.rootView = SettingScreen(actionModel: self.actionModle)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setActions() {
        self.actionModle.backClick.sink{ [weak self] in
            FireBaseEvent.send(eventName: EventName.settingCloseClick)
            guard let self else {return}
            self.navigationController?.popViewController(animated: true)
        }.store(in: &cancellables)
        
        self.actionModle.onToVip.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.settingToVipClick)
            guard let self else {return}
            ConvertViewController.present()
        }.store(in: &cancellables)
        
        #if DEBUG
        // 添加沙盒测试功能（仅在DEBUG模式下可用）
        self.actionModle.onSandboxTest.sink { [weak self] in
            guard let self else { return }
            
            // 创建加载提示
            let loadingAlert = UIAlertController(title: Language.setting_checking_sandbox, message: Language.setting_please_wait, preferredStyle: .alert)
            self.present(loadingAlert, animated: true)
            
            // 执行诊断
            Task {
                let report = await LocalPurchaseManager.shared.performFullDiagnostic()
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        // 显示诊断结果
                        let resultAlert = UIAlertController(title: Language.setting_sandbox_test_result, message: report, preferredStyle: .alert)
                        
                        // 添加测试购买按钮
                        resultAlert.addAction(UIAlertAction(title: Language.setting_test_purchase, style: .default) { _ in
                            self.testPurchase()
                        })
                        
                        // 添加恢复购买按钮
                        resultAlert.addAction(UIAlertAction(title: Language.setting_restore_purchase, style: .default) { _ in
                            self.testRestore()
                        })
                        
                        resultAlert.addAction(UIAlertAction(title: Language.setting_close, style: .cancel))
                        
                        self.present(resultAlert, animated: true)
                    }
                }
            }
        }.store(in: &cancellables)
        #endif
        
        self.actionModle.onNavigateToRate.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.settingToRateClick)
            guard let self else {return}
            if let url = Config.shareAppUrl, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }.store(in: &cancellables)
        
        self.actionModle.onNavigateToShare.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.settingShareAppClick)
            guard let self else {return}
            let activityViewController = UIActivityViewController(activityItems: [Config.shareAppUrl!], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }.store(in: &cancellables)
        
        self.actionModle.onNavigateToAbout.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.settingAboutUsClick)
            guard let self else {return}
            self.navigationController?.pushViewController(AboutViewController(), animated: true)
        }.store(in: &cancellables)
        
        self.actionModle.onNavigateToAccountManagement.sink{ [weak self] in
            FireBaseEvent.send(eventName: EventName.settingManageAccountClick)
            guard let self else {return}
            self.navigationController?.pushViewController(AccountManagerController(), animated: true)
        }.store(in: &cancellables)
        
        self.actionModle.onSuggestion.sink{ [weak self] in
            FireBaseEvent.send(eventName: EventName.settingSuggestionClick)
            guard let self else {return}
            self.navigationController?.pushViewController(SuggestionController(), animated: true)
        }.store(in: &cancellables)
        
        self.actionModle.onNavigateToPrivacyPolicy.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.settingPrivacyClick)
            guard let self else {return}
            let vc = WebViewController(url: Config.URL_PRIVACY_POLICY, title: Language.text_privacy_policy, from: "setting")
            self.navigationController?.present(vc, animated: true)
        }.store(in: &cancellables)
        
        self.actionModle.onNavigateToTerms.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.settingTeamServiceClick)
            guard let self else {return}
            let vc = WebViewController(url: Config.URL_TERMS_OF_USE, title: Language.text_terms_of_use, from: "setting")
            self.navigationController?.present(vc, animated: true)
        }.store(in: &cancellables)
        
        self.actionModle.onNavigateToLanguage.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.settingSetLanguageClick)
            guard let self else {return}
            let languageVC = LanguageSelectionViewController()

            if let sheet = languageVC.sheetPresentationController {
                sheet.detents = [.custom { context in
                    return context.maximumDetentValue * (4.0/5.0) // 屏幕高度的2/3
                }]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
            
            self.present(languageVC, animated: true, completion: nil)
        }.store(in: &cancellables)
    }
    
    // MARK: - Purchase Test Methods
    private func testPurchase() {
        // 选择产品进行购买
        let alert = UIAlertController(title: Language.setting_select_product, message: nil, preferredStyle: .actionSheet)
        
        let products = LocalPurchaseManager.shared.products
        if products.isEmpty {
            let errorAlert = UIAlertController(title: Language.setting_cannot_purchase, message: Language.setting_load_products_first, preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: Language.setting_confirm, style: .default))
            self.present(errorAlert, animated: true)
            return
        }
        
        for product in products {
            alert.addAction(UIAlertAction(title: "\(product.displayName) - \(product.displayPrice)", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.purchaseProduct(product.id)
            })
        }
        
        alert.addAction(UIAlertAction(title: Language.setting_cancel, style: .cancel))
        
        // 适配 iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        self.present(alert, animated: true)
    }
    
    private func purchaseProduct(_ productId: String) {
        let loadingAlert = UIAlertController(title: Language.setting_purchasing, message: Language.setting_please_wait, preferredStyle: .alert)
        self.present(loadingAlert, animated: true)
        
        Task {
            do {
                let success = try await LocalPurchaseManager.shared.purchase(productId)
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let resultAlert = UIAlertController(
                            title: success ? Language.setting_purchase_success : Language.setting_purchase_failed, 
                            message: success ? Language.setting_purchase_success_message : Language.setting_purchase_failed_message,
                            preferredStyle: .alert
                        )
                        resultAlert.addAction(UIAlertAction(title: Language.setting_confirm, style: .default))
                        self.present(resultAlert, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let errorAlert = UIAlertController(
                            title: Language.setting_purchase_error,
                            message: String(format: Language.setting_error_message, error.localizedDescription),
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: Language.setting_confirm, style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
    
    private func testRestore() {
        let loadingAlert = UIAlertController(title: Language.setting_restoring_purchase, message: Language.setting_please_wait, preferredStyle: .alert)
        self.present(loadingAlert, animated: true)
        
        Task {
            do {
                try await LocalPurchaseManager.shared.restore()
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let isVIP = LocalPurchaseManager.checkVIPStatus
                        let vipStatusText = isVIP ? Language.setting_vip_activated : Language.setting_vip_not_activated
                        let resultAlert = UIAlertController(
                            title: Language.setting_restore_complete,
                            message: String(format: Language.setting_vip_status, vipStatusText),
                            preferredStyle: .alert
                        )
                        resultAlert.addAction(UIAlertAction(title: Language.setting_confirm, style: .default))
                        self.present(resultAlert, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let errorAlert = UIAlertController(
                            title: Language.setting_restore_failed,
                            message: String(format: Language.setting_error_message, error.localizedDescription),
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: Language.setting_confirm, style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
}
