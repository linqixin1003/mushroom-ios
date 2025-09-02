# Design Document: Debug Price Mocking

## Overview

The Debug Price Mocking feature will provide a simple mechanism for overriding subscription prices during development and testing. This design focuses on a direct, lightweight approach to modify the price display in the ConvertPage UI without requiring complex infrastructure. The implementation will be exclusively for DEBUG builds and will have no impact on RELEASE builds.

## Architecture

The price mocking system will use a simple approach:

1. **Direct Property Extension**: Add computed properties to LocalPurchaseManager that provide mocked prices in DEBUG mode.
2. **Conditional Compilation**: Use Swift's `#if DEBUG` to ensure that all mocking code is excluded from release builds.
3. **Minimal Changes**: Focus on modifying only what's necessary to achieve the price mocking functionality.

## Components and Interfaces

### LocalPurchaseManager Extension

We'll extend the LocalPurchaseManager class with debug-only properties that provide mocked prices:

```swift
#if DEBUG
extension LocalPurchaseManager {
    // Debug flag to enable/disable price mocking
    public static var isMockingEnabled: Bool = false
    
    // Mocked price values
    public static var mockedYearlyPrice: String = "$39.99"
    public static var mockedMonthlyPrice: String = "$4.99"
    
    // Override the yearlyPrice and monthlyPrice computed properties
    var debugYearlyPrice: String {
        return LocalPurchaseManager.isMockingEnabled ? 
            LocalPurchaseManager.mockedYearlyPrice : 
            self.products.first(where: { $0.id == LocalPurchaseManager.ProductID.yearlyWithTrial })?.displayPrice ?? "?"
    }
    
    var debugMonthlyPrice: String {
        return LocalPurchaseManager.isMockingEnabled ? 
            LocalPurchaseManager.mockedMonthlyPrice : 
            self.products.first(where: { $0.id == LocalPurchaseManager.ProductID.monthly })?.displayPrice ?? "?"
    }
}
#endif
```

### ConvertPage Modifications

The ConvertPage will be updated to use the debug price properties when in DEBUG mode:

```swift
private var yearlyPrice: String {
    #if DEBUG
    return self.purchaseManager.debugYearlyPrice
    #else
    return self.purchaseManager.products.first(where: { $0.id == LocalPurchaseManager.ProductID.yearlyWithTrial })?.displayPrice ?? "?"
    #endif
}

private var monthlyPrice: String {
    #if DEBUG
    return self.purchaseManager.debugMonthlyPrice
    #else
    return self.purchaseManager.products.first(where: { $0.id == LocalPurchaseManager.ProductID.monthly })?.displayPrice ?? "?"
    #endif
}
```

## Integration Points

The mocking system will integrate with the existing codebase at these points:

1. **LocalPurchaseManager.swift**: Add debug extensions for mocked prices.
2. **ConvertPage.swift**: Update the yearlyPrice and monthlyPrice computed properties to use the debug versions when in DEBUG mode.
3. **SandboxTestHelper.swift**: Add methods to enable/disable price mocking and set mocked prices.

## Testing Strategy

The testing strategy will be straightforward:

1. **Manual Testing**: Verify that enabling price mocking shows the correct mocked prices in the ConvertPage UI.
2. **Visual Verification**: Confirm that the UI displays correctly with the mocked prices.
3. **Toggle Testing**: Test that enabling and disabling mocking works as expected.

## Security Considerations

Since this is a debug-only feature, security concerns are minimal. However, we will ensure:

1. **Release Build Protection**: All mocking code will be excluded from release builds using conditional compilation.
2. **No Persistent Changes**: Mocking will not affect any actual purchase functionality.

## Implementation Plan

The implementation will follow these steps:

1. Add debug extensions to LocalPurchaseManager
2. Update ConvertPage to use the debug price properties when in DEBUG mode
3. Add methods to SandboxTestHelper to control price mocking
4. Test the implementation manually