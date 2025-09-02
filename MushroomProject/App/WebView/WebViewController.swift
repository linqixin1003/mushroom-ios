

import UIKit
import WebKit
import SnapKit

private let kObserverKey = "estimatedProgress"

class WebViewController: BaseViewController {
    
    let url: String
    let displayTitle: String
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.webViewOpen, closeEventName: EventName.aboutUsClose)
    init(url: String, title: String, from: String) {
        self.url = url
        self.displayTitle = title
        super.init(from: from)
    }
    
    private var isPresentStyle: Bool {
        return self.navigationController == nil || self.navigationController?.viewControllers.count == 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var hideNavigationBar: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.load(urlString: self.url)
    }
    
    deinit {
        self.webView.removeObserver(self, forKeyPath: kObserverKey, context: nil)
    }
    
    // MARK: - Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let target = object as? WKWebView, target == self.webView {
            if let newProgree = change?[.newKey] as? Double {
                self.progressView.alpha = 1
                self.progressView.setProgress(Float(newProgree), animated: true)
                if newProgree >= 1 {
                    UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut) {
                        self.progressView.alpha = 0
                    } completion: { (finished) in
                        self.progressView.setProgress(0, animated: false)
                    }
                }
            }
        }
    }
    
    override func setNavigationView() {
        self.navigationView.backgroundColor = .white
        if self.isPresentStyle {
            self.navigationView.addRightItem(self.closeButton)
        } else {
            self.navigationView.addLeftItem(self.backButton)
        }
        self.navigationView.title = self.displayTitle
    }
    
    override func backButtonClick() {
        if self.webView.canGoBack {
            self.webView.goBack()
        } else {
            if self.isPresentStyle {
                self.dismiss(animated: true, completion: nil)
            } else {
                FireBaseEvent.send(eventName: EventName.webViewCloseClick, params: [EventParam.url: self.url])
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func closeButtonClick() {
        if self.isPresentStyle {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func addViews() {
        self.view.addSubview(self.webView)
        self.view.addSubview(self.progressView)
    }
    
    override func addConstraints() {
        self.webView.snp.makeConstraints { (make) in
            make.top.equalTo(self.navigationView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.progressView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self.webView)
        }
    }
    
    func load(urlString: String) {
        if let url = URL(string: urlString) {
            self.load(url: url)
        } else {
            debugPrint("[webview] \(urlString) invalid")
        }
    }
    
    func load(url: URL) {
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
    
    // MARK: - Lazy Load
    lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.scrollView.backgroundColor = self.webViewCardBackgroundColor
        webView.backgroundColor = self.webViewCardBackgroundColor
        webView.scrollView.bounces = false
//        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: kObserverKey, options: .new, context: nil)
        return webView
    }()
    
    lazy var progressView: UIProgressView = {
        let view = UIProgressView(frame: .init(x: 0, y: 0, width: ScreenWidth, height: 0))
        view.tintColor = .themeBG
        view.trackTintColor = .white
        return view
    }()

    var webViewCardBackgroundColor: UIColor { .white }
}

//extension WebViewController: WKNavigationDelegate {
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        let url = navigationAction.request.url
//        if let path = url?.path {
//            if path == "/cookie-control" {
//                self.cookieControlAction()
//                decisionHandler(.cancel)
//                return
//            }
//        }
//        decisionHandler(.allow)
//    }
//}
