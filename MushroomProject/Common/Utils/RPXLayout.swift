
import Foundation
import UIKit

public typealias AppRpx = AppResponsiveLayout

@objc public class AppResponsiveLayout: NSObject {
    private override init() {
        // do nothing
    }
    private static let shared = AppResponsiveLayout.init()

    @objc var scale: CGFloat {
        UIScreen.main.scale
    }
    
    private var _sampleWidth: CGFloat = 375.0
    private lazy var _ratio: CGFloat = UIScreen.main.bounds.size.width / _sampleWidth
    
    /// 视觉稿的 sample 宽度, default is 375
    @objc public static var sampleWith: CGFloat {
        get { AppResponsiveLayout.shared._sampleWidth }
        set {
            AppResponsiveLayout.shared._sampleWidth = newValue
            AppResponsiveLayout.shared._ratio = UIScreen.main.bounds.size.width / AppResponsiveLayout.shared._sampleWidth
        }
    }
    
    /// ipad zoom scale. default is 1.5
    @objc public static var ipadZoomScale: CGFloat = 1.5
    
    /// default means width ratio
    @objc static public var ratio: CGFloat {
        get { AppResponsiveLayout.shared._ratio }
    }
    
    public static func roundToNearestZeroOrFive(_ number: CGFloat) -> CGFloat {
        let scaledNumber = number * 10
        let integerPart = floor(scaledNumber)
        let decimalPart = scaledNumber - integerPart
        let roundedDecimal: Double
        if decimalPart < 0.25 {
            roundedDecimal = 0.0
        } else if decimalPart < 0.75 {
            roundedDecimal = 0.5
        } else {
            roundedDecimal = 1.0
        }
        let roundedNumber = (integerPart + roundedDecimal) / 10
        return roundedNumber
    }
}

public extension CGFloat {
    var rpx: CGFloat {
        get {
            return rpx(ipad: self * AppResponsiveLayout.ipadZoomScale)
        }
    }
    
    func rpx(ipad: CGFloat) -> CGFloat {
        let value = UIDevice.current.userInterfaceIdiom == .pad ? ipad : self * AppResponsiveLayout.ratio
        return AppResponsiveLayout.roundToNearestZeroOrFive(value)
    }
}

public extension Int {
    var rpx: CGFloat {
        get {
            return rpx(ipad: CGFloat(self) * AppResponsiveLayout.ipadZoomScale)
        }
    }
    
    func rpx(ipad: CGFloat) -> CGFloat {
        let value = UIDevice.current.userInterfaceIdiom == .pad ? ipad : CGFloat(self) * AppResponsiveLayout.ratio
        return AppResponsiveLayout.roundToNearestZeroOrFive(value)
    }
}

public extension Double {
    var rpx: CGFloat {
        get {
            return rpx(ipad: self * AppResponsiveLayout.ipadZoomScale)
        }
    }
    
    func rpx(ipad: CGFloat) -> CGFloat {
        let value = UIDevice.current.userInterfaceIdiom == .pad ? ipad : self * AppResponsiveLayout.ratio
        return AppResponsiveLayout.roundToNearestZeroOrFive(value)
    }
}

@objc public extension NSNumber {
    @objc var rpx: CGFloat {
        return rpx(ipad: self.doubleValue * AppResponsiveLayout.ipadZoomScale)
    }
    
    @objc func rpx(ipad: CGFloat) -> CGFloat {
        let value = UIDevice.current.userInterfaceIdiom == .pad ? ipad : self.doubleValue * AppResponsiveLayout.ratio
        return AppResponsiveLayout.roundToNearestZeroOrFive(value)
    }
}

// Add extension for literal numbers
public extension ExpressibleByIntegerLiteral {
    var rpx: CGFloat {
        get {
            let value = Double("\(self)") ?? 0
            return CGFloat(value).rpx
        }
    }
}

public extension ExpressibleByFloatLiteral {
    var rpx: CGFloat {
        get {
            let value = Double("\(self)") ?? 0
            return CGFloat(value).rpx
        }
    }
}
