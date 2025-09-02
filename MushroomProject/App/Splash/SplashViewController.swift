import UIKit
import SnapKit

class SplashViewController: BaseViewController {
    let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.splashOpen, closeEventName: EventName.splashClose)
    
    /// 是否正在等待转化页关闭
    private var isWaitingForConvertPageDismiss = false
    /// 是否正在等待挽留页关闭
    private var isWaitingForRetainPageDismiss = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 重置启动标记
        PersistUtil.resetLaunchFlags()
        configUI()
        if PersistUtil.hasAgreeAgreement {
            self.login()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func configUI() {
        self.view.addSubview(self.logoImageView)
        self.view.addSubview(self.agreementView)
        self.logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(300)
            make.centerX.equalToSuperview()
        }
        self.agreementView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private lazy var logoImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "splash_logo")
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
    
    private lazy var agreementView: SplashAgreementView = {
        let view = SplashAgreementView()
        view.continueBtnClickBlock = { [weak self] in
            guard let self else { return }
            PersistUtil.hasAgreeAgreement = true
            
            // 点击Start Now后检查是否需要弹出转化页
            if PersistUtil.canShowConvertPageToday {
                self.showConvertPageBeforeHome()
            } else {
                // 不需要弹出转化页，直接登录进入首页
                self.login()
            }
        }
        
        view.termsOfUseClickBlock = { [weak self] in
            guard let self else { return }
            let vc = WebViewController(url: Config.URL_TERMS_OF_USE, title: Language.text_terms_of_use, from: "splash")
            self.navigationController?.present(vc, animated: true)
        }
        
        view.privacyPolicyClickBlock = { [weak self] in
            guard let self else { return }
            let vc = WebViewController(url: Config.URL_PRIVACY_POLICY, title: Language.text_privacy_policy, from: "splash")
            self.navigationController?.present(vc, animated: true)
        }
        
        view.isHidden = PersistUtil.hasAgreeAgreement
        return view
    }()
    
    /// 在进入首页前弹出转化页
    private func showConvertPageBeforeHome() {
        self.isWaitingForConvertPageDismiss = true
        PersistUtil.incrementTodayConvertPageShowCount()
        
        // 监听转化页关闭通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(convertPageDidDismiss),
            name: NSNotification.Name("ConvertPageDidDismiss"),
            object: nil
        )
        
        // 不需要监听挽留页关闭通知了，因为挽留页会直接跳转到首页
        
        // 传递启动页流程标记
        ConvertViewController.present(isFromSplashFlow: true)
        debugPrint("[ConvertPage] Presented from Start Now - count: \(PersistUtil.todayConvertPageShowCount)")
    }
    
    @objc private func convertPageDidDismiss() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ConvertPageDidDismiss"), object: nil)
        self.isWaitingForConvertPageDismiss = false
        
        debugPrint("[ConvertPage] Dismissed from splash flow, retain page will handle navigation")
        // 转化页关闭后会自动弹出挽留页，挽留页关闭后会直接进入首页
        // 这里不需要做任何操作
    }
}

extension SplashViewController {
    
    private func initDevice() {
        Task {
            let success = await UserRepository.initDeviceAsync()
            debugPrint("[testInitDevice] success: \(success)")
            if !success {
                // show Error page
                return
            }
            await MainActor.run {
                self.toHomePage()
            }
        }
    }
    
    private func login() {
        // 如果正在等待转化页或挽留页关闭，不执行登录
        guard !isWaitingForConvertPageDismiss && !isWaitingForRetainPageDismiss else {
            debugPrint("[Login] Waiting for convert/retain page dismiss, skipping login")
            return
        }
        
        Task {
            let success = await UserRepository.loginAsync()
            debugPrint("[login] success: \(success)")
            if !success {
                // show Error page
                return
            }
            await MainActor.run {
                FireBaseEvent.configPublicParam()
                
                // 只有在用户已经同意协议且没有等待弹出页面关闭的情况下，才检查是否需要弹出转化页
                if PersistUtil.hasAgreeAgreement && !self.isWaitingForConvertPageDismiss && !self.isWaitingForRetainPageDismiss {
                    self.checkAndShowConvertPageOnAppLaunch()
                }
                
                self.toHomePage()
            }
        }
    }
    
    /// 检查并在app启动时弹出转化页（每天最多2次，且本次启动未弹出过）
    private func checkAndShowConvertPageOnAppLaunch() {
        // 清理旧记录
        PersistUtil.cleanupOldConvertPageRecords()
        
        // 检查今天是否还可以弹出转化页
        guard PersistUtil.canShowConvertPageToday else {
            debugPrint("[ConvertPage] Cannot show - count: \(PersistUtil.todayConvertPageShowCount), this launch: \(PersistUtil.hasShownConvertPageThisLaunch)")
            return
        }
        
        // 延迟1秒弹出，确保主页面已经加载完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            PersistUtil.incrementTodayConvertPageShowCount()
            // 这里不是从启动页流程，所以传递 false
            ConvertViewController.present(isFromSplashFlow: false)
            debugPrint("[ConvertPage] Presented on app launch - count: \(PersistUtil.todayConvertPageShowCount)")
        }
    }
    
    private func toHomePage() {

        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }

        
        guard let window = KeyWindow() else {
            return
        }
        window.rootViewController = TabBarController()
    }
}
