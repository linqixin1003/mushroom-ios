//
//  ConvertViewController.swift
//  RockProject
//
//  Created by conalin on 2025/5/26.
//

import SwiftUI
import Combine

class ConvertViewController: BaseHostingViewController<ConvertPage> {
    private let memo = "0"
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.cameraOpen, closeEventName: EventName.cameraClose)
    
    // 保存用户选择的sku
    private var selectedSku: String = LocalPurchaseManager.ProductID.yearlyWithTrial
    /// 标记是否来自启动页流程
    private let isFromSplashFlow: Bool
    
    static func present(isFromSplashFlow: Bool = false) {
        let vc = ConvertViewController(isFromSplashFlow: isFromSplashFlow)
        let nav = BaseNavigationViewController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        UIViewController.topViewController()?.present(nav, animated: true)
    }
    
    let actionModel = ConvertActionModel()
    private var cancellables = Set<AnyCancellable>()
    
    init(isFromSplashFlow: Bool = false) {
        self.isFromSplashFlow = isFromSplashFlow
        super.init(rootView: ConvertPage(
            actionModel: self.actionModel
        ))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置UI
        setupUI()
        
        // 设置事件监听
        setActions()
        
        // 检查产品是否已加载
        if LocalPurchaseManager.shared.products.isEmpty {
            debugPrint("[ConvertPage] \(Language.debug_manual_request_products)")
            Task {
                await LocalPurchaseManager.shared.requestProducts()
                await MainActor.run {
                    debugPrint(String(format: "[ConvertPage] \(Language.debug_request_complete)", LocalPurchaseManager.shared.products.count))
                    self.updateRootView()
                }
            }
        }
        
        debugPrint("=========================")
        
        #if DEBUG
        // Debug 模式下添加测试按钮
//        addDebugTestButton()
        #endif
        
    }
    
    private func setupUI() {
        // 设置导航栏
        navigationController?.setNavigationBarHidden(true, animated: false)
        // 设置背景色
        view.backgroundColor = .black
    }
    
    private func setActions() {
        self.actionModel.onCloseClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.billingCloseClick)
            guard let self else { return }
            
            // 直接无动画关闭，然后立即弹出挽留页
            self.dismiss(animated: false) { [weak self] in
                guard let self else { return }
                
                // 发送转化页关闭通知
                NotificationCenter.default.post(name: NSNotification.Name("ConvertPageDidDismiss"), object: nil)
                
                // 立即弹出 RetainViewController，无延迟
                RetainViewController.present(selectedSku: self.selectedSku, isFromSplashFlow: self.isFromSplashFlow)
            }
        }.store(in: &self.cancellables)

        self.actionModel.onPurchaseClick.sink { [weak self] sku in
            FireBaseEvent.send(eventName: EventName.billingBuyVipClick, params: [EventParam.sku: sku, EventParam.memo: "0"])
            guard let self else { return }
            // 保存用户选择的sku
            self.selectedSku = sku
            self.purchase(sku: sku)
        }.store(in: &self.cancellables)
        
        // 添加sku选择监听
        self.actionModel.onSkuChanged.sink { [weak self] sku in
            guard let self else { return }
            self.selectedSku = sku
        }.store(in: &self.cancellables)

        self.actionModel.onTermsOfUseClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.billingTermServiceClick)
            guard let self else { return }
            let vc = WebViewController(url: Config.URL_TERMS_OF_USE, title: Language.text_terms_of_use, from: "convert")
            self.navigationController?.present(vc, animated: true)
        }.store(in: &self.cancellables)

        self.actionModel.onPrivacyPolicyClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.billingPrivacyClick)
            guard let self else { return }
            let vc = WebViewController(url: Config.URL_PRIVACY_POLICY, title: Language.text_privacy_policy, from: "convert")
            self.navigationController?.present(vc, animated: true)
        }.store(in: &self.cancellables)
        self.actionModel.onRestoreClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.billingRestoreClick)
            guard let self else { return }
            self.restore()
        }.store(in: &self.cancellables)
    }
    private func restore() {
        LoadingUtil.showLoading()
        Task {
            do {
                try await LocalPurchaseManager.shared.restore()
                await MainActor.run {
                    LoadingUtil.dismiss()
                    // 检查是否已经订阅
                    if LocalPurchaseManager.shared.isVIP {
                        // 购买成功，关闭页面
                        self.dismiss(animated: true)
                        // 发送转化页关闭通知
                        NotificationCenter.default.post(name: NSNotification.Name("ConvertPageDidDismiss"), object: nil)
                    } else {
                        ToastUtil.showToast(Language.purchase_no_purchases_to_restore)
                    }
                }
            } catch {
                await MainActor.run {
                    LoadingUtil.dismiss()
                    ToastUtil.showToast(error.localizedDescription)
                }
            }
        }
    }
    
    private func purchase(sku: String) {
        LoadingUtil.showLoading()
        Task {
            do {
                let success = try await LocalPurchaseManager.shared.purchase(sku)
                await MainActor.run {
                    LoadingUtil.dismiss()
                    if success {
                        // 购买成功，关闭页面
                        self.dismiss(animated: true)
                        // 发送转化页关闭通知
                        NotificationCenter.default.post(name: NSNotification.Name("ConvertPageDidDismiss"), object: nil)
                    } else {
                        FireBaseEvent.send(eventName: EventName.billingPayFailed, params: [EventParam.sku: sku, EventParam.memo: "0"])
                        ToastUtil.showToast(Language.text_common_error_try_again)
                    }
                }
            } catch {
                await MainActor.run {
                    LoadingUtil.dismiss()
                    FireBaseEvent.send(eventName: EventName.billingPayFailed, params: [EventParam.sku: sku, EventParam.memo: "0"])
                    ToastUtil.showToast(error.localizedDescription)
                }
            }
        }
    }
    
    /// 直接进入首页
    private func goToHomePage() {
        DispatchQueue.main.async {
            guard let window = KeyWindow() else { return }
            window.rootViewController = TabBarController()
            debugPrint("[ConvertPage] Payment successful, went to home page directly")
        }
    }
    
    /// 更新根视图以刷新价格信息
    private func updateRootView() {
        self.rootView = ConvertPage(
            actionModel: self.actionModel
        )
    }
    
    private func addDebugTestButton() {
        // 在安全区域顶部添加一个隐藏的测试按钮
        let testButton = UIButton(type: .system)
        testButton.setTitle(Language.debug_refresh_products, for: .normal)
        testButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.8)
        testButton.setTitleColor(.white, for: .normal)
        testButton.layer.cornerRadius = 8
        testButton.translatesAutoresizingMaskIntoConstraints = false
        
        testButton.addTarget(self, action: #selector(debugRefreshProducts), for: .touchUpInside)
        
        view.addSubview(testButton)
        NSLayoutConstraint.activate([
            testButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            testButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            testButton.widthAnchor.constraint(equalToConstant: 140),
            testButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }

    @objc private func debugRefreshProducts() {
        debugPrint("[ConvertPage] \(Language.debug_manual_request_products)")
        Task {
            await LocalPurchaseManager.shared.requestProducts()
            await MainActor.run {
                debugPrint("[ConvertPage] \(Language.debug_manual_refresh_complete)")
                self.updateRootView()
            }
        }
    }
    
}

