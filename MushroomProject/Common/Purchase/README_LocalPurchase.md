# 本地购买验证服务使用指南

这是一个完全基于客户端的应用内购买验证系统，无需服务器端验证。

## 文件结构

```
MushroomProject/Common/Purchase/
├── LocalPurchaseManager.swift      # 核心购买管理器
├── PurchaseHelper.swift           # 购买帮助工具类
├── PurchaseUsageExample.swift     # 使用示例
├── IAPManager.swift               # 原有的IAP管理器（可保留）
├── SubscriptionManager.swift      # 原有的订阅管理器（可保留）
└── README_LocalPurchase.md        # 本文档
```

## 核心特性

- ✅ 完全本地验证，无需服务器
- ✅ 支持多种产品类型（订阅、一次性购买）
- ✅ 自动处理购买状态持久化
- ✅ 简单易用的API
- ✅ 完整的错误处理
- ✅ iPad适配
- ✅ 调试功能支持
- ✅ VIP状态变化通知

## 快速开始

### 1. 最简单的使用方式

```swift
// 显示购买选项（推荐）
PurchaseHelper.showPurchaseOptions(from: self) { success, message in
    if success {
        print("购买成功！")
        // 更新UI或执行其他逻辑
    }
}
```

### 2. 检查VIP状态

```swift
if PurchaseHelper.isVIP {
    // 用户是VIP，显示高级功能
} else {
    // 用户不是VIP，显示升级提示
}
```

### 3. 恢复购买

```swift
PurchaseHelper.restorePurchases(from: self) { success, message in
    if success {
        print("恢复购买成功")
    }
}
```

## 详细API说明

### PurchaseHelper (推荐使用)

#### showPurchaseOptions
显示所有可用的购买选项，自动处理产品加载和选择界面。

```swift
static func showPurchaseOptions(
    from viewController: UIViewController, 
    completion: @escaping (Bool, String?) -> Void
)
```

#### purchaseProduct
直接购买指定产品。

```swift
static func purchaseProduct(
    productId: String, 
    from viewController: UIViewController, 
    completion: @escaping (Bool, String?) -> Void
)
```

#### restorePurchases
恢复之前的购买。

```swift
static func restorePurchases(
    from viewController: UIViewController, 
    completion: @escaping (Bool, String?) -> Void
)
```

#### isVIP
检查当前VIP状态。

```swift
static var isVIP: Bool { get }
```

#### vipInfo
获取详细的VIP信息。

```swift
static var vipInfo: (isVIP: Bool, purchaseDate: Date?, productId: String?) { get }
```

### LocalPurchaseManager (高级使用)

如果您需要更细粒度的控制，可以直接使用 `LocalPurchaseManager`：

```swift
// 加载产品
LocalPurchaseManager.shared.loadProducts { products in
    // 处理产品列表
}

// 购买产品
LocalPurchaseManager.shared.purchase(product: product) { success, error in
    // 处理购买结果
}

// 检查VIP状态
let isVIP = LocalPurchaseManager.shared.isPremium
```

## 集成步骤

### 1. 在您的 ViewController 中集成

```swift
class MyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVIPStatusListener()
        updateUIBasedOnVIPStatus()
    }
    
    private func setupVIPStatusListener() {
        NotificationCenter.default.addObserver(
            forName: .VipInfoChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let isVIP = notification.object as? Bool {
                self?.updateUIBasedOnVIPStatus()
            }
        }
    }
    
    private func updateUIBasedOnVIPStatus() {
        if PurchaseHelper.isVIP {
            // 更新UI为VIP状态
        } else {
            // 更新UI为普通用户状态
        }
    }
    
    @IBAction func upgradeButtonTapped(_ sender: UIButton) {
        PurchaseHelper.showPurchaseOptions(from: self) { success, message in
            // 处理购买结果
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
```

### 2. 在功能入口处检查VIP状态

```swift
func usePremiumFeature() {
    if PurchaseHelper.isVIP {
        // 执行高级功能
        performPremiumFeature()
    } else {
        // 显示升级提示
        showUpgradePrompt()
    }
}

private func showUpgradePrompt() {
    let alert = UIAlertController(
        title: "高级功能",
        message: "此功能需要升级到高级版",
        preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "立即升级", style: .default) { _ in
        PurchaseHelper.showPurchaseOptions(from: self) { success, message in
            if success {
                self.performPremiumFeature()
            }
        }
    })
    
    alert.addAction(UIAlertAction(title: "取消", style: .cancel))
    present(alert, animated: true)
}
```

## 产品配置

在 `LocalPurchaseManager.swift` 中配置您的产品ID：

```swift
private let productIds: Set<String> = [
    "premium_yearly_7days_free",  // 年度订阅（7天免费试用）
    "premium_yearly",             // 年度订阅
    "premium_monthly"             // 月度订阅
]
```

## 调试功能

在调试模式下，您可以使用以下功能来测试购买流程：

```swift
#if DEBUG
// 显示调试选项
PurchaseHelper.showDebugOptions(from: self)

// 手动设置VIP状态
LocalPurchaseManager.shared.debugSetVIPStatus(true)

// 清除所有购买记录
LocalPurchaseManager.shared.debugClearPurchases()
#endif
```

## 通知系统

系统会在VIP状态发生变化时发送通知：

```swift
// 监听VIP状态变化
NotificationCenter.default.addObserver(
    forName: .VipInfoChanged,
    object: nil,
    queue: .main
) { notification in
    if let isVIP = notification.object as? Bool {
        // 更新UI
    }
}
```

## 数据持久化

购买状态会自动保存到 UserDefaults：

- `local_vip_status`: VIP状态
- `local_purchase_date`: 购买日期  
- `local_product_id`: 购买的产品ID

## 与现有系统的兼容性

本系统与您现有的 `SubscriptionManager` 和 `PersistUtil.isVip` 完全兼容：

- 购买成功后会自动设置 `PersistUtil.isVip = true`
- 会发送 `.VipInfoChanged` 通知，与现有系统保持一致
- 可以与现有的 StoreKit 2.0 系统并存

## 安全注意事项

本系统是纯客户端验证，适用于以下场景：

✅ **适合的场景：**
- 小型应用或工具类应用
- 对安全要求不是特别严格的场景
- 希望简化后端复杂度的情况
- 快速原型或MVP产品

⚠️ **注意事项：**
- 技术高手可能会绕过客户端验证
- 对于高价值内容，建议结合服务器端验证
- 定期检查和更新防护措施

## 常见问题

### Q: 如何在设置页面显示VIP状态？
A: 使用 `PurchaseHelper.vipInfo` 获取详细信息，然后根据状态更新UI。

### Q: 用户重新安装应用后VIP状态会丢失吗？
A: 本地存储会丢失，但用户可以通过"恢复购买"功能重新获得VIP状态。

### Q: 如何处理网络问题导致的产品加载失败？
A: `PurchaseHelper` 会自动显示错误提示，建议用户检查网络后重试。

### Q: 可以自定义购买界面吗？
A: 可以直接使用 `LocalPurchaseManager` 创建自定义界面，或修改 `PurchaseHelper` 的实现。

## 示例代码

查看 `PurchaseUsageExample.swift` 文件获取更多详细的使用示例和集成方案。 