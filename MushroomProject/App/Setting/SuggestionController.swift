import SwiftUI
import Combine
import MessageUI
class SuggestionController:BaseHostingViewController<SuggestionScreen>, MFMailComposeViewControllerDelegate{
    private let action = SuggestionAction()
    private let viewModel = SuggestionViewModel()
    private var cancellable = Set<AnyCancellable>()
    private let sendOpenAndCloseEvent = SendOpenAndCloseEvent(openEventName: EventName.suggestionOpen, closeEventName: EventName.suggestionClose)
    init(){
        super.init(rootView: SuggestionScreen(action: self.action, viewModel: self.viewModel),title:"Suggestion")
    }
    
    @MainActor required dynamic public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.action.onBack.sink { [weak self] in
            FireBaseEvent.send(eventName: EventName.suggestionCloseClick)
            guard let self else {return}
            self.navigationController?.popViewController(animated: true)
        }.store(in: &cancellable)
        
        self.action.onEmailInput.sink { [weak self] email in
            guard let self else {return}
            self.viewModel.email = email
            
        }.store(in: &cancellable)
        self.action.onDescriptionInput.sink { [weak self] desc in
            guard let self else {return}
            self.viewModel.desc = desc
        }.store(in: &cancellable)
        self.action.onSend.sink { [weak self] Int in
            FireBaseEvent.send(eventName: EventName.suggestionSendClick)
            guard let self else {return}
            if MFMailComposeViewController.canSendMail() {
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self

                // 指定收件人邮箱
                mailComposer.setToRecipients([Config.EMAIL])
                // 设置邮件主题
                mailComposer.setSubject(Language.suggestion_email_subject)
                // 设置邮件正文
                mailComposer.setMessageBody(self.viewModel.desc + "\n" + self.viewModel.email, isHTML: false)

                // 遍历 viewModel.images 并添加图片
                self.viewModel.images.enumerated().forEach { index, image in
                    if let imageData = image.jpegData(compressionQuality: 1.0) {
                        let fileName = "image_\(index).jpg"
                        mailComposer.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: fileName)
                    }
                }
                present(mailComposer, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: Language.suggestion_cant_send_email, message: Language.suggestion_email_setup_message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Language.suggestion_confirm, style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }.store(in: &cancellable)
    }
}
