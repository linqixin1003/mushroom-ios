

import Foundation
import UIKit
import SnapKit

class NetworkRequestErrorView: UIView {
    var handler: (()->())?
    
    init() {
        super.init(frame: .zero)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.addSubview(self.tipLabel)
        self.addSubview(self.retryButton)
        
        self.tipLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        
        self.retryButton.snp.makeConstraints { make in
            make.height.equalTo(buttonHeight)
            make.centerX.bottom.equalToSuperview()
            make.top.equalTo(tipLabel.snp.bottom).offset(16.0)
        }
    }
    
    private var buttonHeight: Double {
        return 44.0
    }
    
    // MARK: - Lazy load
    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.text = "No connection. Please try again later"
        label.textColor = .fromHex(0x666666)
        label.font = .systemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Try Again", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .medium)
        button.backgroundColor = UIColor.fromHex(0x007AFF) // iOS蓝色
        button.layer.cornerRadius = buttonHeight/2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        
        // 设置按钮宽度
        button.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(120)
        }
        
        // 添加点击效果
        button.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        button.addTarget(self, action: #selector(onRetryButtonClick), for: .touchUpInside)
        return button
    }()
    
    @objc private func onRetryButtonClick() {
        self.handler?()
    }
    
    @objc private func buttonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.retryButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.retryButton.alpha = 0.8
        }
    }
    
    @objc private func buttonTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.retryButton.transform = CGAffineTransform.identity
            self.retryButton.alpha = 1.0
        }
    }
}
