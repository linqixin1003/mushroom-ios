
import UIKit

class TabBarCenterItem: TabBarCenterBaseItem {
    @objc override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.backgroundColor = .primary
        self.layer.cornerRadius = self.size.width / 2.0
        self.layer.masksToBounds = true
        self.button.setImage(UIImage(named: "icon_tabbar_camera"), for: .normal)
    }
    
    override var bottomEdge: Double {
        return 6.0
    }
}
