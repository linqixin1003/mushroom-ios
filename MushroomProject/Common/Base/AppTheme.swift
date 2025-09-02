import UIKit
import SwiftUI

// MARK: Theme
extension UIColor {
    
    class var accent: UIColor { return UIColor.blue }
    class var pageBG: UIColor { return .fromHex(0xF3F5F4) }
    
    class var themeBG: UIColor { return .fromHex(0x530EA7) }
    class var splashBG: UIColor { return .fromHex(0x5A00C7) }
    class var appPink: UIColor { return .fromHex(0xF7A8FA) }
    class var primary: UIColor { return .fromHex(0xB98245) }
    class var appText: UIColor { return .fromHex(0x172B4D) }
    class var appTextLight: UIColor { return .fromHex(0x868686) }
    class var colorTextLightText1: UIColor { return .fromHex(0x0F1721) }
    class var colorChatContent: UIColor { return .fromHex(0x1D2939) }
}

// MARK: SwiftUI Color Extension
extension Color {
    static var accent: Color { Color.blue }
    static var pageBG: Color { Color(hex: 0xF3F5F4) }
    static var themeBG: Color { Color(hex: 0x530EA7) }
    static var splashBG: Color { Color(hex: 0x5A00C7) }
    static var primary: Color { Color(hex: 0xB98245) }
    static var appPink: Color { Color(hex: 0xF7A8FA) }
    static var appText: Color { Color(hex: 0x172B4D) }
    static var appTextLight: Color { Color(hex: 0x868686) }
    static var colorTextLightText1: Color { Color(hex: 0x0F1721) }
    static var colorChatContent: Color { Color(hex: 0x1D2939) }
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            alpha: alpha
        )
    }
    
    class func fromHex(_ hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: hex, alpha: alpha)
    }
}

extension Color {
    init(hex: Int, alpha: CGFloat = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: Font
public extension UIFont {
    
    // MARK: - Kanit
    class func blackKanit(_ size: CGFloat)            -> UIFont { UIFont.init(name: "Kanit-Black", size: size) ?? .boldSystemFont(ofSize: size) }
    class func boldKanit(_ size: CGFloat)             -> UIFont { UIFont.init(name: "Kanit-Bold", size: size) ?? .boldSystemFont(ofSize: size) }
    class func italicKanit(_ size: CGFloat)           -> UIFont { UIFont.init(name: "Kanit-Italic", size: size) ?? .italicSystemFont(ofSize: size) }
    class func lightKanit(_ size: CGFloat)            -> UIFont { UIFont.init(name: "Kanit-Light", size: size) ?? .systemFont(ofSize: size) }
    class func mediumKanit(_ size: CGFloat)           -> UIFont { UIFont.init(name: "Kanit-Medium", size: size) ?? .systemFont(ofSize: size) }
    class func regularKanit(_ size: CGFloat)          -> UIFont { UIFont.init(name: "Kanit-Regular", size: size) ?? .systemFont(ofSize: size) }
    class func semiboldKanit(_ size: CGFloat)         -> UIFont { UIFont.init(name: "Kanit-SemiBold", size: size) ?? .systemFont(ofSize: size) }
    class func thinKanit(_ size: CGFloat)             -> UIFont { UIFont.init(name: "Kanit-Thin", size: size) ?? .systemFont(ofSize: size) }
    
}
