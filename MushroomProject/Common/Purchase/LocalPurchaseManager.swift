import Foundation
import StoreKit

// MARK: - Constants (在类外部定义，避免 MainActor 隔离问题)
private let vipStatusKey = "local_vip_status"
private let purchaseDateKey = "local_purchase_date"
private let productIdKey = "local_product_id"

/// 本地购买验证管理器 - 基于 StoreKit 2.0，无需服务器验证
@MainActor
class LocalPurchaseManager: ObservableObject {
    static let shared = LocalPurchaseManager()
    
    /// 非隔离的静态方法，用于检查VIP状态
    nonisolated static var checkVIPStatus: Bool {
        return UserDefaults.standard.bool(forKey: vipStatusKey)
    }
    
    // MARK: - Published Properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var isVIP: Bool = false {
        didSet {
            // 发送通知
            NotificationCenter.default.post(name: .VipInfoChanged, object: self, userInfo: ["isVIP": isVIP])
            // 同步更新本地存储
            UserDefaults.standard.set(isVIP, forKey: vipStatusKey)
        }
    }
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    // 添加支付初始化状态
    @Published private(set) var initializationStatus: String = "Not started"
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    private var retryCount: Int = 0
    private var maxRetryCount: Int = 3
    
    // MARK: - Price Formatting
    /// 格式化价格，去掉 "US" 前缀
    private func formatPrice(_ product: Product) -> String {
        let originalPrice = product.displayPrice
        // 去掉 "US" 前缀，保留 $ 符号
        if originalPrice.hasPrefix("US$") {
            return String(originalPrice.dropFirst(2)) // 去掉 "US"，保留 "$"
        }
        return originalPrice
    }
    
    // 产品ID配置
    public enum ProductID {
        static let yearlyWithTrial = "rock_premium_yearly_7days_free"
        static let yearly = "rock_premium_yearly"
        static let monthly = "rock_premium_monthly"
        
        static var all: [String] {
            return [yearlyWithTrial, yearly, monthly]
        }
    }
    
    // MARK: - Error Types
    enum PurchaseError: LocalizedError {
        case productNotFound
        case verificationFailed(Error)
        case pending
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .productNotFound:
                return "Product not found"
            case .verificationFailed(let error):
                return "Verification failed: \(error.localizedDescription)"
            case .pending:
                return "Purchase is pending"
            case .unknown:
                return "Unknown error occurred"
            }
        }
    }
    
    private init() {
        // 启动事务监听器
        updateListenerTask = listenForTransactions()
        initializationStatus = "Transaction listener started"
        
        // 加载本地状态
        loadVIPStatus()
        initializationStatus = "Local VIP status loaded"
        
        // 初始化时自动加载产品
        Task {
            initializationStatus = "Requesting products..."
            await requestProducts()
            await updateSubscriptionStatus()
            initializationStatus = "Initialization completed"
            
            await logEnvironmentInfo()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// 请求产品信息
    func requestProducts() async {
        isLoading = true
        errorMessage = nil
        retryCount = 0
        initializationStatus = "Starting product request..."
        
        await requestProductsWithRetry()
    }
    
    /// 带重试机制的产品请求
    private func requestProductsWithRetry() async {
        do {
            initializationStatus = "Requesting products (attempt \(retryCount + 1)/\(maxRetryCount))..."
            print("🔄 Requesting products (attempt \(retryCount + 1)/\(maxRetryCount))...")
            print("Product IDs: \(ProductID.all)")
        
            
            // 请求产品
            let loadedProducts = try await Product.products(for: ProductID.all)
            
            
            initializationStatus = "Products received: \(loadedProducts.count)"
            print("✅ Raw products response: \(loadedProducts.count) products")
            for product in loadedProducts {
                print("- \(product.id): \(product.displayName) - \(product.displayPrice)")
            }
            
            
            // 验证产品数据
            let validProducts = loadedProducts.filter { product in
                let isValid = !product.id.isEmpty && !product.displayName.isEmpty
                
                if !isValid {
                    print("⚠️ Invalid product detected: \(product.id)")
                }
                
                return isValid
            }
            
            await MainActor.run {
                self.products = validProducts
                self.isLoading = false
                self.errorMessage = nil
                self.initializationStatus = "Products loaded successfully: \(validProducts.count)"
            }
            
            // 更新订阅状态
            await updateSubscriptionStatus()
            
            
            print("✅ Products loaded successfully: \(validProducts.count)")
            
            
        } catch {
            initializationStatus = "Error loading products: \(error.localizedDescription)"
            print("❌ Failed to load products (attempt \(retryCount + 1)): \(error)")
            
            
            retryCount += 1
            
            if retryCount < maxRetryCount {
                initializationStatus = "Retrying in 2 seconds... (attempt \(retryCount + 1))"
                print("🔄 Retrying in 2 seconds...")
                
                
                // 等待2秒后重试
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await requestProductsWithRetry()
            } else {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.initializationStatus = "Failed after \(maxRetryCount) attempts"
                }
                
                
                print("❌ Failed to load products after \(maxRetryCount) attempts")
                print("Final error: \(error)")
                
            }
        }
    }
    
    /// 购买产品
    func purchase(_ productId: String) async throws -> Bool {
        guard let product = products.first(where: { $0.id == productId }) else {
            throw PurchaseError.productNotFound
        }
        
        // 开始购买
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                print("🔍 Transaction Details:")
                print("- Product ID: \(transaction.productID)")
                print("- Original ID: \(transaction.originalID)")
                print("- Expiration Date: \(String(describing: transaction.expirationDate))")
                print("- Purchase Date: \(transaction.purchaseDate)")
                
                // 处理交易
                await updateSubscriptionStatus()
                await transaction.finish()
                return isVIP
                
            case .unverified(_, let error):
                throw PurchaseError.verificationFailed(error)
            }
            
        case .userCancelled:
            return false
            
        case .pending:
            throw PurchaseError.pending
            
        @unknown default:
            throw PurchaseError.unknown
        }
    }
    
    /// 恢复购买
    func restore() async throws {
        // 使用正确的 StoreKit 2.0 恢复购买 API
        for productId in ProductID.all {
            if let verificationResult = await Transaction.latest(for: productId) {
                switch verificationResult {
                case .verified(let transaction):
                    await transaction.finish()
                case .unverified(_, let error):
                    print("⚠️ Transaction verification failed: \(error.localizedDescription)")
                }
            }
        }
        await updateSubscriptionStatus()
    }
    
    /// 获取格式化后的价格（去掉US前缀）
    func getFormattedPrice(for productId: String) -> String {
        guard let product = products.first(where: { $0.id == productId }) else {
            return "?"
        }
        return formatPrice(product)
    }
    
    // MARK: - Private Methods
    
    /// 监听交易更新
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.handle(transactionResult: result)
            }
        }
    }
    
    /// 处理交易结果
    private func handle(transactionResult result: VerificationResult<Transaction>) async {
        await MainActor.run {
            switch result {
            case .verified(let transaction):
                // 更新订阅状态
                Task {
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                }
                
            case .unverified(_, _):
                // 验证失败，不更新状态
                break
            }
        }
    }
    
    /// 更新订阅状态
    private func updateSubscriptionStatus() async {
        var purchasedProductIds = Set<String>()
        var latestExpirationDate: Date?
        var isValid = false
        
        // 检查所有交易
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                // 只处理自动续期订阅
                guard transaction.productType == .autoRenewable else { continue }
                
                // 记录产品ID
                purchasedProductIds.insert(transaction.productID)
                
                // 检查是否已过期
                if let expirationDate = transaction.expirationDate,
                   expirationDate > Date() {
                    isValid = true
                    
                    // 更新最新的过期时间
                    if latestExpirationDate == nil || expirationDate > latestExpirationDate! {
                        latestExpirationDate = expirationDate
                    }
                }
            }
        }
        
        // 更新状态
        await MainActor.run {
            self.isVIP = isValid
            
            // 保存状态到本地
            UserDefaults.standard.set(isValid, forKey: vipStatusKey)
            UserDefaults.standard.set(latestExpirationDate, forKey: purchaseDateKey)
            if let latestProductId = purchasedProductIds.first {
                UserDefaults.standard.set(latestProductId, forKey: productIdKey)
            }
        }
    }
    
    /// 加载本地VIP状态
    private func loadVIPStatus() {
        isVIP = UserDefaults.standard.bool(forKey: vipStatusKey)
    }
    
    // MARK: - Debug Methods (Only available in DEBUG builds)
    
    #if DEBUG
    private func logEnvironmentInfo() async {
        print("🔍 StoreKit Environment Info:")
        print("Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        print("Products requested: \(ProductID.all)")
        print("Products loaded: \(products.count)")
        
        if products.isEmpty {
            print("❌ No products loaded!")
            print("Possible issues:")
            print("1. Products not configured in App Store Connect")
            print("2. Bundle ID mismatch")
            print("3. Network connectivity issues")
            print("4. Sandbox account not signed in")
        } else {
            print("✅ Products loaded successfully:")
            for product in products {
                print("- Product ID: \(product.id)")
                print("  Display Name: \(product.displayName)")
                print("  Price: \(product.displayPrice)")
                print("  Type: \(product.type)")
                
                if let subscription = product.subscription {
                    print("  Subscription Group: \(subscription.subscriptionGroupID)")
                    print("  Subscription Period: \(subscription.subscriptionPeriod)")
                    if let introOffer = subscription.introductoryOffer {
                        print("  Intro Offer: \(introOffer.displayPrice) for \(introOffer.period)")
                    }
                }
                print("  ---")
            }
        }
        
        // 检查本地存储状态
        print("Local Storage:")
        print("- VIP Status: \(isVIP)")
        if let date = UserDefaults.standard.object(forKey: purchaseDateKey) as? Date {
            print("- Purchase Date: \(date)")
        }
        if let productId = UserDefaults.standard.string(forKey: productIdKey) {
            print("- Product ID: \(productId)")
        }
    }
    
    /// 强制重新加载产品（调试用）
    func debugReloadProducts() async {
        print("🔄 Force reloading products...")
        await requestProducts()
        await logEnvironmentInfo()
    }
    
    /// 检查沙盒配置
    func debugCheckSandboxSetup() async -> String {
        var report = "=== 🔍 Sandbox Environment Check ===\n\n"
        
        // 检查 Bundle ID
        let bundleId = Bundle.main.bundleIdentifier ?? "unknown"
        report += "Bundle ID: \(bundleId)\n"
        if bundleId != "com.stone.snap" {
            report += "⚠️ Bundle ID mismatch! Expected: com.stone.snap, Got: \(bundleId)\n"
        }
        
        // 检查产品配置
        report += "\nProduct Configuration:\n"
        report += "Expected Product IDs: \(ProductID.all)\n\n"
        
        // 尝试加载产品
        await requestProducts()
        
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
        
        report += "\n==============================\n"
        return report
    }
    
    /// 测试价格格式化
    func debugTestPriceFormatting() async -> String {
        var report = "🧪 Testing price formatting...\n\n"
        
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
    
    /// 获取初始化状态报告
    public func getInitializationReport() -> String {
        var report = "=== 💳 Payment System Status ===\n\n"
        
        // 初始化状态
        report += "Initialization Status:\n"
        report += "- Current: \(initializationStatus)\n"
        report += "- Loading: \(isLoading ? "Yes" : "No")\n"
        if let error = errorMessage {
            report += "- Error: ❌ \(error)\n"
        }
        
        // 产品状态
        report += "\nProduct Status:\n"
        if products.isEmpty {
            report += "❌ No products loaded\n"
        } else {
            report += "✅ \(products.count) products loaded\n"
            for product in products {
                report += "- \(product.id): \(product.displayName)\n"
            }
        }
        
        // 订阅状态
        report += "\nSubscription Status:\n"
        if LocalPurchaseManager.checkVIPStatus {
            report += "✅ Active subscription found\n"
        } else {
            report += "❌ No active subscription\n"
        }
        
        return report
    }
    
    /// 公共调试方法 - 检查沙盒环境和产品配置
    func performFullDiagnostic() async -> String {
        var report = "=== 🔍 Full Purchase System Diagnostic ===\n\n"
        
        // 添加初始化状态报告
        report += getInitializationReport()
        report += "\n"
        
        report += await debugCheckSandboxSetup()
        report += "\n"
        report += await debugTestPriceFormatting()
        report += "=== End Diagnostic ===\n"
        return report
    }
    #else
    // Release版本中的空实现
    private func logEnvironmentInfo() async {
        // Release版本中不执行任何操作
    }
    #endif
    
} 
