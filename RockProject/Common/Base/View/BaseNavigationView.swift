

import Foundation
import SnapKit
import UIKit

open class BaseNavigationView: UIView {
    
    var leftMargin: CGFloat = 10
    var rightMargin: CGFloat = 10
    var itemMargin: CGFloat = 10
    
    public var leftItems: [UIView] = []
    public var rightItems: [UIView] = []
    
    public var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    public var navHeight: Double {
        return StatusBarHeight + NavigationBarHeight
    }
    
    var itemHeight: Double {
        return NavigationBarHeight
    }
    
    public init() {
        super.init(frame: .zero)
        
        addSubview(leftItemsView)
        addSubview(titleView)
        titleView.addSubview(titleLabel)
        addSubview(rightItemsView)
        
        updateConstraint()
    }
    
    func updateConstraint() {
        leftItemsView.snp.remakeConstraints { make in
            make.height.equalTo(itemHeight)
            make.bottom.leading.equalTo(0).priority(.required)
            if let item = leftItems.last {
                make.trailing.greaterThanOrEqualTo(item.snp.trailing).priority(.required)
            }
        }
        leftItemsView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        rightItemsView.snp.remakeConstraints { make in
            make.height.equalTo(itemHeight)
            make.bottom.trailing.equalTo(0).priority(.required)
            if let item = rightItems.first {
                make.leading.lessThanOrEqualTo(item.snp.leading).priority(.required)
            }
        }
        rightItemsView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        updateTitleViewConstraint()
        
        titleLabel.snp.remakeConstraints { make in
            make.top.bottom.equalTo(0)
            make.leading.trailing.greaterThanOrEqualToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    func clearConstraints() {
        for subview in self.subviews {
            subview.snp.removeConstraints()
        }
        self.snp.removeConstraints()
    }
    
    private func updateTitleViewConstraint() {
        if leftItems.count > 0 && !self.leftItemsView.isHidden {
            titleView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview().priority(.high)
                make.height.equalTo(itemHeight)
                make.bottom.equalTo(0)
                make.leading.greaterThanOrEqualTo(leftItemsView.snp.trailing).priority(.required)
                make.trailing.lessThanOrEqualTo(rightItemsView.snp.leading).priority(.required)
            }
        } else {
            titleView.snp.remakeConstraints { make in
                make.height.equalTo(itemHeight)
                make.bottom.equalTo(0)
                make.leading.equalTo(0)
                make.trailing.lessThanOrEqualTo(rightItemsView.snp.leading).priority(.required)
            }
        }
    }
    
    public func addLeftItems(_ items: [UIView]) {
        for item in items {
            addLeftItem(item)
        }
    }
    
    public func addLeftItem(_ item: UIView) {
        if leftItems.contains(where: { $0 == item } ) {
            return
        }
        
        let lastItem = leftItems.last
        leftItems.append(item)
        leftItemsView.addSubview(item)
        
        item.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(itemHeight)
            make.width.greaterThanOrEqualTo(itemHeight)
            if let lastItem {
                make.leading.equalTo(lastItem.snp.trailing).offset(itemMargin)
            } else {
                make.leading.equalTo(leftMargin)
            }
        }
        item.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.updateConstraint()
    }
    
    public func addRightItems(_ items: [UIView]) {
        for item in items.reversed() {
            addRightItem(item)
        }
    }
    
    public func addRightItem(_ item: UIView) {
        if rightItems.contains(where: { $0 == item } ) {
            return
        }
        
        let firstItem = rightItems.first
        rightItems.insert(item, at: 0)
        rightItemsView.addSubview(item)
        
        item.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(itemHeight)
            make.width.greaterThanOrEqualTo(itemHeight)
            if let firstItem {
                make.trailing.equalTo(firstItem.snp.leading).offset(-itemMargin)
            } else {
                make.trailing.equalTo(-rightMargin)
            }
        }
        item.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.updateConstraint()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Item ContentView
     public lazy var titleView: UIView = {
        let view = UIView()
        return view
    }()
    
    public lazy var leftItemsView: UIView = {
        let view = UIView()
        return view
    }()
    
    public lazy var rightItemsView: UIView = {
        let view = UIView()
        return view
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .fromHex(0x000000)
        label.font = .systemFont(ofSize: 18.0)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
}
