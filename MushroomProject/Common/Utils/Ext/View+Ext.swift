
import UIKit

extension UIView {
    
    public func addSubviews(_ views: [UIView]) {
        views.forEach { v in
            self.addSubview(v)
        }
    }
    
    public var cornerRadius: Double {
        get {
            return self.layer.cornerRadius
        }
        
        set {
            self.layer.cornerCurve = .continuous
            self.layer.cornerRadius =  newValue
        }
    }
}
