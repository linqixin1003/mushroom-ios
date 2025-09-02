
import UIKit
import SnapKit

let TAB_CENTER_ITEM_SIZE = 62.0

@objc
class TabBarCenterBaseItem: UIView {

    @objc
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(self.button)
        self.button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc var size: CGSize {
        return CGSize(width: TAB_CENTER_ITEM_SIZE, height: TAB_CENTER_ITEM_SIZE)
    }
    
    @objc var bottomEdge: Double {
        return 0.0
    }
    
    //MARK: - lazy load
    @objc private(set) lazy var button: UIButton = {
        let button = UIButton()
        return button
    }()
}
