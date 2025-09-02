//
//  RetainViewController.swift
//  RockProject
//
//  Created by conalin on 2025/5/26.
//

import SwiftUI
import Combine
import StoreKit

class RetainViewController: BaseHostingViewController<RetainPage> {
    private let selectedSku: String
    private let memo = "1" // 区别于convert页面的memo
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.cameraOpen, closeEventName: EventName.cameraClose)
    
    /// 标记是否来自启动页流程
    private let isFromSplashFlow: Bool
    
    static func present(selectedSku: String, isFromSplashFlow: Bool = false) {
        let vc = RetainViewController(selectedSku: selectedSku, isFromSplashFlow: isFromSplashFlow)
        let nav = BaseNavigationViewController(rootViewController: vc)
        
        // 修改弹出方式：直接覆盖，不显示推出动画
        nav.modalPresentationStyle = .overFullScreen
        nav.modalTransitionStyle = .crossDissolve
        
        // 或者可以使用无动画的方式，直接覆盖
        UIViewController.topViewController()?.present(nav, animated: false)
    }
    
    let actionModel = RetainActionModel()
    private var cancellables = Set<AnyCancellable>()
    
    init(selectedSku: String, isFromSplashFlow: Bool = false) {
        self.selectedSku = selectedSku
        self.isFromSplashFlow = isFromSplashFlow
        super.init(rootView: RetainPage(
            selectedSku: selectedSku,
            actionModel: self.actionModel
        ))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setActions()
    }
    
    private func setActions() {
        self.actionModel.onCloseClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.billingCloseClick)
            guard let self else { return }
            self.dismissAndHandleNavigation()
        }.store(in: &self.cancellables)
        
        self.actionModel.onRestoreClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.billingRestoreClick)
            guard let self else { return }
            self.restore()
        }.store(in: &self.cancellables)

        self.actionModel.onPurchaseClick.sink { [weak self] sku in
            FireBaseEvent.send(eventName: EventName.billingBuyVipClick, params: [EventParam.sku: sku, EventParam.memo: self?.memo ?? "1"])
            guard let self else { return }
            self.purchase(sku: sku)
        }.store(in: &self.cancellables)
    }
    
    /// 关闭页面并处理导航逻辑
    private func dismissAndHandleNavigation() {
        // 关闭时也使用淡出效果
        self.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            
            if self.isFromSplashFlow {
                // 如果来自启动页流程，直接进入首页
                self.goToHomePage()
            } else {
                // 如果不是来自启动页流程，发送关闭通知（保持原有逻辑）
                NotificationCenter.default.post(name: NSNotification.Name("RetainPageDidDismiss"), object: nil)
            }
        }
    }
    
    /// 直接进入首页
    private func goToHomePage() {
        DispatchQueue.main.async {
            guard let window = KeyWindow() else { return }
            window.rootViewController = TabBarController()
            debugPrint("[RetainPage] Dismissed and went to home page directly")
        }
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
                        ToastUtil.showToast(Language.purchase_success)
                        self.dismissAndHandleNavigation()
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
                        self.dismissAndHandleNavigation()
                    } else {
                        FireBaseEvent.send(eventName: EventName.billingPayFailed, params: [EventParam.sku: sku, EventParam.memo: self.memo])
                        ToastUtil.showToast(Language.text_common_error_try_again)
                    }
                }
            } catch {
                await MainActor.run {
                    LoadingUtil.dismiss()
                    FireBaseEvent.send(eventName: EventName.billingPayFailed, params: [EventParam.sku: sku, EventParam.memo: self.memo])
                    ToastUtil.showToast(error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func purchaseButtonTapped() {
        PurchaseHelper.showPurchaseOptions(from: self) { [weak self] success, message in
            if success {
                self?.dismissAndHandleNavigation()
            } else if let message = message {
                ToastUtil.showToast(message)
            }
        }
    }
}

