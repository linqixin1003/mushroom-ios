import UIKit
import SwiftUI
import Combine

class SearchViewController: BaseHostingViewController<SearchPage> {
    
    let viewModel = SearchViewModel()
    let actionModel = SearchActionModel()
    
    private var cancellables = Set<AnyCancellable>()
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.searchOpen, closeEventName: EventName.searchClose)
    init() {
        super.init(rootView: SearchPage(viewModel: self.viewModel, actionModel: self.actionModel))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setActions()
        self.observeNotifications()
    }
    
    private func setActions() {
        
        self.actionModel.resultItemClick.sink { [weak self] simpleMushroom in
            FireBaseEvent.send(eventName: EventName.searchItemClick, params: [EventParam.uid: simpleMushroom.id])
            guard let self else { return }
            let vc = DetailViewController(id: simpleMushroom.id)
            self.navigationController?.pushViewController(vc, animated: true)
        }.store(in: &cancellables)
    }
    
    override func observeNotifications() {
        // 监听语言变化通知
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: LocalizationManager.languageChangedNotification, object: nil)
    }
    
    @objc
    private func languageChanged() {
        // 强制刷新SwiftUI视图
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 重新创建rootView以应用新的语言
            let newRootView = SearchPage(viewModel: self.viewModel, actionModel: self.actionModel)
            self.rootView = newRootView
            self.hostingController.rootView = newRootView
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
