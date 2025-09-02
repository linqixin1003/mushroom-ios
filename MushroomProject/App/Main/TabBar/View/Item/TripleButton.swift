
import UIKit
import SnapKit

@objc
enum TripleButtonEvent: Int {
    case select = 0
    case clickOnSelect
}

@objc
protocol TripleButtonDelegage: NSObjectProtocol {
    func tripleButton(_ sender: AnyObject, event: TripleButtonEvent)
}

@objc
class TripleButton: UIView {
    @objc var selected: Bool = false
    @objc weak var delegate: TripleButtonDelegage?
    
    @objc
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(self.button)
        self.button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //sub class can override this method
    @objc func showUIForClickOnSelectedState() {}
    
    //MARK: - Private methods
    @objc private func buttonClickAction() {
        if !selected {
            self.selected = true
            self.delegate?.tripleButton(self, event: .select)
        } else {
            self.showUIForClickOnSelectedState()
            self.delegate?.tripleButton(self, event: .clickOnSelect)
        }
    }
    
    //MARK: - Lazy load
    private lazy var button: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(buttonClickAction), for: .touchUpInside)
        return btn
    }()
}
