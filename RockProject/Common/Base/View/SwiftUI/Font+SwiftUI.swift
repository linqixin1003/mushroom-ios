
import SwiftUI

public extension Font {
    static func regular(_ size: CGFloat)  -> Font { .system(size: size, weight: .regular) }
    static func thin(_ size: CGFloat)     -> Font { .system(size: size, weight: .thin) }
    static func light(_ size: CGFloat)    -> Font { .system(size: size, weight: .light) }
    static func medium(_ size: CGFloat)   -> Font { .system(size: size, weight: .medium) }
    static func semibold(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold) }
    static func bold(_ size: CGFloat)     -> Font { .system(size: size, weight: .bold) }
    static func heavy(_ size: CGFloat)    -> Font { .system(size: size, weight: .heavy) }
    static func black(_ size: CGFloat)    -> Font { .system(size: size, weight: .black) }
}
