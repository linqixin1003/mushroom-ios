import Foundation
import StoreKit

#if DEBUG
/// 沙盒测试助手 - 用于调试和测试应用内购买功能 (仅在DEBUG模式下可用)
public class SandboxTestHelper {
    public static let shared = SandboxTestHelper()
    
    private init() {}
    
    /// 检查沙盒环境配置
    public func checkSandboxSetup() async -> String {
        var report = "=== 🔍 Sandbox Environment Check ===\n\n"
        
        // 检查 Bundle ID
        let bundleId = Bundle.main.bundleIdentifier ?? "unknown"
        report += "Bundle ID: \(bundleId)\n"
        if bundleId != "com.mushroom.snap" {
            report += "⚠️ Bundle ID mismatch! Expected: com.mushroom.snap, Got: \(bundleId)\n"
        }
        
        // 检查产品配置
        report += "\nProduct Configuration:\n"
        let productIds = LocalPurchaseManager.ProductID.all
        report += "Expected Product IDs: \(productIds)\n\n"
        
        // 检查产品加载状态
        let manager = LocalPurchaseManager.shared
        await manager.requestProducts()
        let products = manager.products
        
        if products.isEmpty {
            report += "❌ Failed to load products!\n"
            report += "Troubleshooting steps:\n"
            report += "1. Check App Store Connect product configuration\n"
            report += "2. Verify products are in 'Ready to Submit' status\n"
            report += "3. Check Bundle ID matches App Store Connect\n"
            report += "4. Ensure signed in with sandbox test account\n"
            report += "5. Check network connectivity\n"
        } else {
            report += "✅ Products loaded successfully\n"
            for product in products {
                report += "- \(product.id): \(product.displayName) (\(product.displayPrice))\n"
            }
        }
        
        report += "\n=== End Sandbox Check ===\n"
        return report
    }
    
    /// 测试价格格式化
    public func testPriceFormatting() async -> String {
        var report = "🧪 Testing price formatting...\n\n"
        let products = LocalPurchaseManager.shared.products
        
        if products.isEmpty {
            report += "❌ No products available to test price formatting\n"
            return report
        }
        
        for product in products {
            report += "Product: \(product.id)\n"
            report += "  Display Name: \(product.displayName)\n"
            report += "  Price: \(product.price)\n"
            report += "  Display Price: \(product.displayPrice)\n"
            
            // 测试价格格式化
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceFormatStyle.locale
            
            if let formattedPrice = formatter.string(from: product.price as NSNumber) {
                report += "  Formatted Price: \(formattedPrice)\n"
            } else {
                report += "  ❌ Failed to format price\n"
            }
            report += "\n"
        }
        
        return report
    }
    
    /// 执行完整诊断
    public func performFullDiagnostic() async -> String {
        var report = "=== 🔍 Full Purchase System Diagnostic ===\n\n"
        
        // 检查沙盒环境
        report += await checkSandboxSetup()
        report += "\n"
        
        // 测试价格格式化
        report += await testPriceFormatting()
        
        report += "=== End Diagnostic ===\n"
        return report
    }
}
#else
/// Release版本中的空实现
public class SandboxTestHelper {
    public static let shared = SandboxTestHelper()
    private init() {}
    
    // Release版本中所有方法都返回空字符串或不执行任何操作
    public func checkSandboxSetup() async -> String { return "" }
    public func testPriceFormatting() async -> String { return "" }
    public func performFullDiagnostic() async -> String { return "" }
}
#endif 