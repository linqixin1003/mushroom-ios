import SwiftUI
import Combine
import Foundation

class AccountManagerController:BaseHostingViewController<AccountManagerScreen>{
    private var cancellable = Set<AnyCancellable>()
    private var action = AccountManangerAction()
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.accountManagerOpen, closeEventName: EventName.accountManagerClose)
    init(){
        super.init(rootView:AccountManagerScreen(action: self.action), title: Language.account_manager_title)
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.action.backClick.sink{ [weak self] in
            FireBaseEvent.send(eventName: EventName.accountManagerCloseClick)
            guard let self else {return}
            self.navigationController?.popViewController(animated: true)
        }.store(in: &cancellable)
        self.action.onDeleteClick.sink{ [weak self] in
            FireBaseEvent.send(eventName: EventName.accountManagerDeleteConfirmClick)
            guard let self else {return}
            Task{
                let req = AccountManagerRequest(lang: Language.account_manager_language)
                let result: String? = try? await ApiRequest.requestAsync(request: req)
                await MainActor.run {
                    let success = result == "success"
                    if success {
                        PersistUtil.clearAllData()
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.restartApp()
                        }
                    }
                }
            }
        }.store(in: &cancellable)
    }
}
