import UIKit
import StoreKit

#if DEBUG
/// 购买功能使用示例 (仅在DEBUG模式下可用)
public class PurchaseUsageExample {
    
    /// 沙盒测试：查询价格并显示结果
    @MainActor
    public static func testSandboxPricing(from viewController: UIViewController) {
        let alert = UIAlertController(title: Language.purchase_testing_sandbox_pricing, message: Language.purchase_please_wait, preferredStyle: .alert)
        viewController.present(alert, animated: true)
        
        Task {
            let manager = LocalPurchaseManager.shared
            
            // 先运行诊断
            
            await manager.performFullDiagnostic()
            
            
            // 请求产品信息
            await manager.requestProducts()
            
            await MainActor.run {
                alert.dismiss(animated: true) {
                    showPricingResults(from: viewController, manager: manager)
                }
            }
        }
    }
    
    /// 显示价格查询结果
    @MainActor
    private static func showPricingResults(from viewController: UIViewController, manager: LocalPurchaseManager) {
        let alert = UIAlertController(title: Language.purchase_sandbox_test_results, message: "", preferredStyle: .alert)
        
        var message = ""
        
        // 检查是否有错误
        if let errorMessage = manager.errorMessage {
            message += "\(Language.purchase_error_info)\n\(errorMessage)\n\n"
        }
        
        // 检查加载状态
        if manager.isLoading {
            message += "\(Language.purchase_loading_status)\n\n"
        }
        
        // 显示产品信息
        let products = manager.products
        if products.isEmpty {
            message += Language.purchase_no_products_error
        } else {
            message += "\(Language.purchase_products_found) \(products.count) products:\n\n"
            
            for (index, product) in products.enumerated() {
                message += "\(index + 1). \(Language.purchase_product_name) \(product.displayName)\n"
                message += "   \(Language.purchase_product_id) \(product.id)\n"
                message += "   \(Language.purchase_product_price) \(product.displayPrice)\n"
                message += "   \(Language.purchase_product_type) \(productTypeString(product.type))\n"
                
                if let subscription = product.subscription {
                    message += "   \(Language.purchase_subscription_period) \(subscriptionPeriodString(subscription.subscriptionPeriod))\n"
                    if let introOffer = subscription.introductoryOffer {
                        message += "   \(Language.purchase_trial_offer) \(introOffer.displayPrice) (\(subscriptionPeriodString(introOffer.period)))\n"
                    }
                }
                message += "\n"
            }
        }
        
        // 显示系统信息
        message += Language.purchase_system_info
        message += "\(Language.purchase_bundle_id) \(Bundle.main.bundleIdentifier ?? Language.purchase_unknown)\n"
        message += "\(Language.purchase_vip_status) \(LocalPurchaseManager.checkVIPStatus ? Language.purchase_vip_yes : Language.purchase_vip_no)\n"
        
        alert.message = message
        
        // 添加操作按钮
        alert.addAction(UIAlertAction(title: Language.purchase_retest, style: .default) { _ in
            testSandboxPricing(from: viewController)
        })
        
        alert.addAction(UIAlertAction(title: Language.purchase_test_purchase, style: .default) { _ in
            testSandboxPurchase(from: viewController)
        })
        
        alert.addAction(UIAlertAction(title: Language.purchase_close, style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    /// 测试沙盒购买
    @MainActor
    public static func testSandboxPurchase(from viewController: UIViewController) {
        let products = LocalPurchaseManager.shared.products
        
        if products.isEmpty {
            let alert = UIAlertController(title: Language.purchase_cannot_purchase, message: Language.purchase_load_products_first, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Language.common_ok, style: .default))
            viewController.present(alert, animated: true)
            return
        }
        
        // 选择产品进行购买
        let alert = UIAlertController(title: Language.purchase_select_product_to_buy, message: nil, preferredStyle: .actionSheet)
        
        for product in products {
            alert.addAction(UIAlertAction(title: "\(product.displayName) - \(product.displayPrice)", style: .default) { _ in
                purchaseProduct(product.id, from: viewController)
            })
        }
        
        alert.addAction(UIAlertAction(title: Language.common_cancel, style: .cancel))
        
        // 适配 iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(alert, animated: true)
    }
    
    /// 购买指定产品
    @MainActor
    private static func purchaseProduct(_ productId: String, from viewController: UIViewController) {
        let loadingAlert = UIAlertController(title: Language.purchase_purchasing, message: Language.purchase_please_wait, preferredStyle: .alert)
        viewController.present(loadingAlert, animated: true)
        
        Task {
            do {
                let success = try await LocalPurchaseManager.shared.purchase(productId)
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let resultAlert = UIAlertController(
                            title: success ? Language.purchase_purchase_success : Language.purchase_purchase_failed,
                            message: success ? Language.purchase_congratulations : Language.purchase_not_completed,
                            preferredStyle: .alert
                        )
                        resultAlert.addAction(UIAlertAction(title: Language.common_ok, style: .default))
                        viewController.present(resultAlert, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let errorAlert = UIAlertController(
                            title: Language.purchase_purchase_error,
                            message: "\(Language.purchase_error_message) \(error.localizedDescription)",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: Language.common_ok, style: .default))
                        viewController.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
    
    /// 恢复购买测试
    @MainActor
    public static func testRestorePurchase(from viewController: UIViewController) {
        let loadingAlert = UIAlertController(title: Language.purchase_restoring_purchases, message: Language.purchase_please_wait, preferredStyle: .alert)
        viewController.present(loadingAlert, animated: true)
        
        Task {
            do {
                try await LocalPurchaseManager.shared.restore()
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let isVIP = LocalPurchaseManager.checkVIPStatus
                        let resultAlert = UIAlertController(
                            title: Language.purchase_restore_complete,
                            message: "\(Language.purchase_vip_status) \(isVIP ? Language.purchase_vip_activated : Language.purchase_vip_not_activated)",
                            preferredStyle: .alert
                        )
                        resultAlert.addAction(UIAlertAction(title: Language.common_ok, style: .default))
                        viewController.present(resultAlert, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let errorAlert = UIAlertController(
                            title: Language.purchase_restore_failed,
                            message: "\(Language.purchase_error_message) \(error.localizedDescription)",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: Language.common_ok, style: .default))
                        viewController.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private static func productTypeString(_ type: Product.ProductType) -> String {
        switch type {
        case .autoRenewable:
            return Language.purchase_auto_renewable
        case .nonRenewable:
            return Language.purchase_non_renewable
        case .consumable:
            return Language.purchase_consumable
        case .nonConsumable:
            return Language.purchase_non_consumable
        default:
            return Language.purchase_unknown_type
        }
    }
    
    private static func subscriptionPeriodString(_ period: Product.SubscriptionPeriod) -> String {
        let unitString: String
        switch period.unit {
        case .day:
            unitString = Language.purchase_day
        case .week:
            unitString = Language.purchase_week
        case .month:
            unitString = Language.purchase_month
        case .year:
            unitString = Language.purchase_year
        @unknown default:
            unitString = Language.purchase_unknown
        }
        return "\(period.value) \(unitString)"
    }
}
#else
/// Release版本中的空实现
public class PurchaseUsageExample {
    // Release版本中所有方法都不执行任何操作
    @MainActor
    public static func testSandboxPricing(from viewController: UIViewController) {
        // Release版本中不执行任何操作
    }
    
    @MainActor
    public static func testSandboxPurchase(from viewController: UIViewController) {
        // Release版本中不执行任何操作
    }
    
    @MainActor
    public static func testRestorePurchase(from viewController: UIViewController) {
        // Release版本中不执行任何操作
    }
}
#endif
