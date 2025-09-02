

import UIKit
import SnapKit

class WelcomeViewController: UIViewController {
    
    static func present(vc: UIViewController) {
        let targetVc = WelcomeViewController()
        targetVc.modalPresentationStyle = .overCurrentContext
        vc.present(targetVc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.addViews()
        self.addConstraints()
    }
    
    private func addViews() {
        self.view.addSubview(self.maskView)
        self.view.addSubview(self.contentContainerView)
        self.contentContainerView.addSubview(self.bgImageView)
        self.contentContainerView.addSubview(self.iconImageView)
        self.contentContainerView.addSubview(self.titleLabel)
        self.contentContainerView.addSubview(self.contentLabel)
        self.contentContainerView.addSubview(self.okBtn)
    }
    
    private func addConstraints() {
        self.maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.contentContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(288)
        }
        self.bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.iconImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(26)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(20)
        }
        self.okBtn.snp.makeConstraints { make in
            make.top.equalTo(self.contentLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
    }
    
    private lazy var maskView: UIView = {
        let view = UIView()
        view.backgroundColor = .fromHex(0x000000, alpha: 0.5)
        return view
    }()
    
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .themeBG
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var bgImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "bg_top"))
        view.contentMode = .scaleToFill
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon_credit_72"))
        view.contentMode = .scaleToFill
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .mediumKanit(22)
        view.textColor = .white
        view.text = Language.welcome_title
        view.numberOfLines = 1
        view.textAlignment = .center
        return view
    }()
    
    private lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.font = .lightKanit(16)
        view.textColor = .white
        view.text = Language.welcome_content
        view.numberOfLines = 0
        view.textAlignment = .center
        return view
    }()
    
    private lazy var okBtn: UIButton = {
        let view = UIButton()
        view.setTitle(Language.welcome_got_it, for: .normal)
        view.setTitleColor(.colorTextLightText1, for: .normal)
        view.titleLabel?.font = .semiboldKanit(16)
        view.backgroundColor = .appPink
        view.layer.cornerRadius = 12
        view.addTarget(self, action: #selector(onOkBtnClick), for: .touchUpInside)
        return view
    }()
    
    @objc
    private func onOkBtnClick() {
        self.dismiss(animated: true)
    }
}
