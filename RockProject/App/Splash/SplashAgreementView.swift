

import UIKit
import SnapKit

class SplashAgreementView: BaseView {
    
    var continueBtnClickBlock: (() -> Void)?
    var termsOfUseClickBlock: (() -> Void)?
    var privacyPolicyClickBlock: (() -> Void)?
    let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.agreementOpen, closeEventName: EventName.agreementClose)
    override func initSubView() {
        self.backgroundColor = .pageBG
        self.addSubview(self.policyContainer)
        self.addSubview(self.policyPrefixLabel)
        self.addSubview(self.continueBtn)
        self.addSubview(self.logoImageView)
        
        self.policyContainer.addSubview(self.termsLabel)
        self.policyContainer.addSubview(self.privacyLabel)
        
        // region policy
        self.policyContainer.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(SafeBottom + 6)
            make.centerX.equalToSuperview()
        }
        self.termsLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }
        self.privacyLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.termsLabel.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        // endregion
        self.policyPrefixLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.policyContainer.snp.top).offset(4)
            make.centerX.equalToSuperview()
        }
        self.continueBtn.snp.makeConstraints { make in
            make.bottom.equalTo(self.policyPrefixLabel.snp.top).offset(-16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
        self.logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(300)
            make.centerX.equalToSuperview()
        }
    }
    
    // region policy
    private lazy var policyContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var termsLabel: UIButton = {
        let view = UIButton()
        view.setTitle("\(Language.text_terms_of_use), ", for: .normal)
        view.setTitleColor(.primary, for: .normal)
        view.titleLabel?.font = .regularKanit(12)
        view.contentEdgeInsets = .zero
        view.addTarget(self, action: #selector(onTermsOfUseClick), for: .touchUpInside)
        return view
    }()
    
    private lazy var privacyLabel: UIButton = {
        let view = UIButton()
        view.setTitle(Language.text_privacy_policy, for: .normal)
        view.setTitleColor(.primary, for: .normal)
        view.titleLabel?.font = .regularKanit(12)
        view.contentEdgeInsets = .zero
        view.addTarget(self, action: #selector(onPrivacyPolicyClick), for: .touchUpInside)
        return view
    }()
    // endregion
    
    private lazy var policyPrefixLabel: UILabel = {
        let view = UILabel()
        view.textColor = .lightGray
        view.font = .regularKanit(12)
        view.text = Language.text_policy_tapping_continue
        return view
    }()
    
    private lazy var continueBtn: UIButton = {
        let view = UIButton()
        view.setTitle(Language.splash_start_now, for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = .semiboldKanit(16)
        view.backgroundColor = .primary
        view.layer.cornerRadius = 12
        view.addTarget(self, action: #selector(onContinueBtnClick), for: .touchUpInside)
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "splash_logo")
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
    
}

extension SplashAgreementView {
    
    @objc
    private func onContinueBtnClick() {
        debugPrint("Splash - onContinueBtnClick")
        self.continueBtnClickBlock?()
    }
    
    @objc
    private func onTermsOfUseClick() {
        debugPrint("Splash - onTermsOfUseClick")
        self.termsOfUseClickBlock?()
    }
    
    @objc
    private func onPrivacyPolicyClick() {
        debugPrint("Splash - onPrivacyPolicyClick")
        self.privacyPolicyClickBlock?()
    }
}
