

import Foundation
import SnapKit
import UIKit

open class BaseViewController: UIViewController {
    
    var from: String = ""
    
    var hideNavigationBar: Bool {
        return true
    }

    var interactivePopDisabled: Bool {
        return false
    }
    
    var navigationViewHeight: Double {
        return self.hideNavigationBar ? 0 : self.navigationView.navHeight
    }
    
    @objc
    init(from: String = "") {
        self.from = from
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .pageBG
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = self.interactivePopDisabled

        self.view.addSubview(navigationView)
        self.navigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.navigationViewHeight)
        }

        setNavigationView()
        addViews()
        addConstraints()
        setupSwiftUIView()
        observeNotifications()
    }

    open override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.isTranslucent = false
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    open func setNavigationView() {

    }

    open func addViews() {

    }

    open func addConstraints() {

    }
    
    open func setupSwiftUIView() {
        
    }
    
    open func observeNotifications() {
        
    }

    @objc open func backButtonClick() {

    }

    @objc open func closeButtonClick() {

    }

    // MARK: - Request Error

    func showRequestFailed() {
        self.view.addSubview(self.errorView)
        self.errorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            if IsIPad {
                make.width.equalTo(400.0)
            } else {
                make.leading.equalTo(40.0)
            }
        }
    }

    // Override this methods
    func retryRequest() {
        // retry
    }

    // MARK: - Lazy load
    private lazy var errorView: NetworkRequestErrorView = {
        let errorView = NetworkRequestErrorView()
        errorView.handler = { [weak self] in
            self?.errorView.removeFromSuperview()
            self?.retryRequest()
        }
        return errorView
    }()

    open lazy var navigationView: BaseNavigationView = {
        let view = BaseNavigationView()
        return view
    }()

    open lazy var backButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "arrow_left_white24"), for: .normal)
        view.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        view.adjustsImageWhenHighlighted = false
        return view
    }()

    open lazy var closeButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.setImage(UIImage(systemName: "xmark"), for: .normal)
        view.tintColor = .black
        view.addTarget(self, action: #selector(closeButtonClick), for: .touchUpInside)
        view.adjustsImageWhenHighlighted = false
        return view
    }()
}

extension BaseViewController: UIGestureRecognizerDelegate {
    /// Disable Pop
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let navigationController = self.navigationController, navigationController.viewControllers.count < 1 {
            return false
        }

        if interactivePopDisabled {
            return false
        }

        return true
    }
}
