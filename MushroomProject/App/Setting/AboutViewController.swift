import Foundation
import Combine
class AboutViewController:BaseHostingViewController<AboutScreen>{
    private let aboutAction = AboutAction()
    private var cancellable = Set<AnyCancellable>()
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.aboutUsOpen, closeEventName: EventName.aboutUsClose)
    init(){
        super.init(rootView: AboutScreen(action: self.aboutAction),title: Language.about_page_title)
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.aboutAction.backClick.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.aboutUsCloseClick)
            guard let self else {return}
            self.navigationController?.popViewController(animated: true)
        }.store(in: &cancellable)
    }
}
