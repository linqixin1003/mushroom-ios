

import UIKit

public let ScreenWidth = UIScreen.main.bounds.size.width
public let ScreenHeight = UIScreen.main.bounds.size.height
public let ScreenScale = UIScreen.main.scale
public let ScreenBounds = UIScreen.main.bounds

public func KeyWindow() -> UIWindow? { UIApplication.shared.windows.first }

public let IsIPad = UIDevice.current.userInterfaceIdiom == .pad
public let IsIPhone5 = ScreenWidth == 320.0

@available(iOS 11.0, *)
public let IsIPhoneX = UIDevice.current.userInterfaceIdiom == .phone && (KeyWindow()?.safeAreaInsets.bottom ?? 0.0) > 0.0

@available(iOS 11.0, *)
public let IPhoneXTopHeight = IsIPhoneX ? (KeyWindow()?.safeAreaInsets.top ?? 0.0) : 0.0

@available(iOS 11.0, *)
public let IPhoneXBottomHeight = IsIPhoneX ? (KeyWindow()?.safeAreaInsets.bottom ?? 0.0) : 0.0

@available(iOS 11.0, *)
public let StatusBarHeight = IsIPhoneX ? IPhoneXTopHeight : 20.0

public let NavigationBarHeight = 44.0

public let SafeTop: CGFloat = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0.0

public let SafeBottom: CGFloat = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0.0

public let SafeNavigationBarHeight = NavigationBarHeight + SafeTop

public var TabBarHeight: Double {
    return SafeBottom + 49.0
}


extension Array {
    
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
