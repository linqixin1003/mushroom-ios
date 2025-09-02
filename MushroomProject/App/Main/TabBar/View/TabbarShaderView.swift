
import UIKit
import SnapKit

@objc
class TabbarShaderView: UIView {
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubviews([line, centerImageView])
        
        self.centerImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 104.0, height: 31.0))
            make.centerX.bottom.equalToSuperview()
        }
        
        self.line.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.6)
        }
    }
    
    @objc var gHeight: Double {
        return 31.0
    }
    
    //MARK: - Lazy load
    private lazy var centerImageView: UIImageView = {
        let centerImageView = UIImageView.init(image: UIImage(named: "bg_navigation_bar1"))
        return centerImageView
    }()
    
    private lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = .fromHex(0xE0E0E0, alpha: 0.7)
        return view
    }()
}
