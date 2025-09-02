import Foundation
import UIKit
import StoreKit

/// 购买帮助工具类 - 提供简化的购买流程
@MainActor
class PurchaseHelper {
    
    /// 显示购买选项
    /// - Parameters:
    ///   - viewController: 当前视图控制器
    ///   - completion: 完成回调 (成功, 错误信息)
    static func showPurchaseOptions(from viewController: UIViewController, completion: @escaping (Bool, String?) -> Void) {
        Task {
            // 先检查是否已经是VIP
            if LocalPurchaseManager.shared.isVIP {
                completion(true, Language.purchase_already_vip)
                return
            }
            
            // 显示加载指示器
            let loadingAlert = createLoadingAlert(message: Language.purchase_loading_products)
            viewController.present(loadingAlert, animated: true)
            
            do {
                // 加载产品
                await LocalPurchaseManager.shared.requestProducts()
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        if LocalPurchaseManager.shared.products.isEmpty {
                            // 无产品可用，显示重试选项
                            showErrorWithRetry(
                                from: viewController,
                                title: Language.purchase_error,
                                message: LocalPurchaseManager.shared.errorMessage ?? Language.purchase_unable_to_load_products,
                                retryAction: {
                                    Task {
                                        await showPurchaseOptions(from: viewController, completion: completion)
                                    }
                                },
                                cancelAction: {
                                    completion(false, Language.purchase_unable_to_load_products)
                                }
                            )
                        } else {
                            // 显示购买选项
                            showProductSelection(products: LocalPurchaseManager.shared.products, from: viewController, completion: completion)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        showErrorWithRetry(
                            from: viewController,
                            title: Language.purchase_error,
                            message: error.localizedDescription,
                            retryAction: {
                                Task {
                                    await showPurchaseOptions(from: viewController, completion: completion)
                                }
                            },
                            cancelAction: {
                                completion(false, error.localizedDescription)
                            }
                        )
                    }
                }
            }
        }
    }
    
    /// 直接购买指定产品
    /// - Parameters:
    ///   - productId: 产品ID
    ///   - viewController: 当前视图控制器
    ///   - completion: 完成回调
    static func purchaseProduct(productId: String, from viewController: UIViewController, completion: @escaping (Bool, String?) -> Void) {
        Task {
            // 检查是否已经是VIP
            if LocalPurchaseManager.shared.isVIP {
                completion(true, Language.purchase_already_vip)
                return
            }
            
            // 显示加载指示器
            let loadingAlert = createLoadingAlert(message: Language.purchase_processing)
            viewController.present(loadingAlert, animated: true)
            
            do {
                // 执行购买
                let success = try await LocalPurchaseManager.shared.purchase(productId)
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        if success {
                            showSuccessAlert(from: viewController) { _ in
                                completion(true, nil)
                            }
                        } else {
                            showAlert(from: viewController, title: Language.purchase_failed, message: Language.purchase_cancelled) { _ in
                                completion(false, Language.purchase_cancelled)
                            }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        showAlert(from: viewController, title: Language.purchase_failed, message: error.localizedDescription) { _ in
                            completion(false, error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    /// 恢复购买
    /// - Parameters:
    ///   - viewController: 当前视图控制器
    ///   - completion: 完成回调
    static func restorePurchases(from viewController: UIViewController, completion: @escaping (Bool, String?) -> Void) {
        Task {
            // 显示加载指示器
            let loadingAlert = createLoadingAlert(message: Language.purchase_restoring)
            viewController.present(loadingAlert, animated: true)
            
            do {
                // 执行恢复
                try await LocalPurchaseManager.shared.restore()
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        showSuccessAlert(from: viewController) { _ in
                            completion(true, nil)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        showAlert(from: viewController, title: Language.purchase_restore_failed, message: error.localizedDescription) { _ in
                            completion(false, error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private static func showProductSelection(products: [Product], from viewController: UIViewController, completion: @escaping (Bool, String?) -> Void) {
        let alert = UIAlertController(title: Language.purchase_select_product, message: nil, preferredStyle: .actionSheet)
        
        // 添加产品选项
        for product in products {
            let action = UIAlertAction(title: "\(product.displayName) - \(product.displayPrice)", style: .default) { _ in
                Task {
                    await purchaseProduct(productId: product.id, from: viewController, completion: completion)
                }
            }
            alert.addAction(action)
        }
        
        // 添加恢复购买选项
        let restoreAction = UIAlertAction(title: Language.purchase_restore, style: .default) { _ in
            Task {
                await restorePurchases(from: viewController, completion: completion)
            }
        }
        alert.addAction(restoreAction)
        
        // 添加取消选项
        let cancelAction = UIAlertAction(title: Language.common_cancel, style: .cancel) { _ in
            completion(false, Language.purchase_cancelled)
        }
        alert.addAction(cancelAction)
        
        // 在 iPad 上需要设置弹出位置
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        viewController.present(alert, animated: true)
    }
    
    private static func createLoadingAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        return alert
    }
    
    private static func showAlert(from viewController: UIViewController, title: String, message: String, completion: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Language.common_ok, style: .default, handler: completion)
        alert.addAction(okAction)
        viewController.present(alert, animated: true)
    }
    
    private static func showSuccessAlert(from viewController: UIViewController, completion: @escaping (UIAlertAction) -> Void) {
        showAlert(from: viewController, title: Language.purchase_success, message: Language.purchase_success_message, completion: completion)
    }
    
    private static func showErrorWithRetry(from viewController: UIViewController, title: String, message: String, retryAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let retryButton = UIAlertAction(title: Language.purchase_retry, style: .default) { _ in
            retryAction()
        }
        alert.addAction(retryButton)
        
        let cancelButton = UIAlertAction(title: Language.common_cancel, style: .cancel) { _ in
            cancelAction()
        }
        alert.addAction(cancelButton)
        
        viewController.present(alert, animated: true)
    }
}
