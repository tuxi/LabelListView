//
//  LabelListView.swift
//  LabelListView
//
//  Created by xiaoyuan on 2021/8/19.
//

import UIKit

public class LabelListView<TagView: Label>: UIView {

    /// 行间距
    public var hSpacing: CGFloat = 10 {
        didSet {
            if hSpacing == oldValue {
                return
            }
            setNeedsUpdateConstraints()
        }
    }
    /// 列间距
    public var vSpacing: CGFloat = 10 {
        didSet {
            if vSpacing == oldValue {
                return
            }
            setNeedsUpdateConstraints()
        }
    }
    
    /// 内容边距
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            updateMyConstraints()
        }
    }
    
    /// 加载小格子
    public var tags: [String] = [] {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    /// 在显示的标签
    private var displayViews = [TagView]()
    /// 准备复用的标签
    private var reuseViews = [TagView]()
    /// 当content的size改变时，重新布局，以填充标签
    private var sizeObserver: WeakBox<SizeObserver>?
    
    private var contentConstraints = [NSLayoutConstraint]()
    private var labsConstraints = [NSLayoutConstraint]()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }
    
    private func makeUI() {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentConstraints = ["H:|[contentView]|", "V:|[contentView]|"].flatMap {
            NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: ["contentView": contentView])
        }
        .activate()
        
        updateMyConstraints()
        
        sizeObserver = WeakBox(box: SizeObserver(target: self.contentView, eventHandler: { [weak self] kayPath in
            self?.setNeedsUpdateConstraints()
        }))
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        let contentWidth = self.contentView.frame.size.width
       
        if contentWidth <= 0 {
            return
        }
        
        prepareForReuse()
        
        // 累计宽度
        var maxX: CGFloat = 0
        // 记录上一个格子
        var beforeLabel: Label?
        
        contentView.removeConstraints(labsConstraints)
        labsConstraints.removeAll()
        
        /// 更新约束
        
        for (index, item) in tags.enumerated() {
            let label = displayViews[index]
            label.text = item
            label.textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            
            let labelSize = label.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
            
            label.layer.cornerRadius = labelSize.height * 0.5
            label.backgroundColor = .red
            
            if let beforeLabel = beforeLabel, (maxX + labelSize.width + hSpacing) > contentWidth {
                // 换到下一行的第一个
                labsConstraints.append(contentsOf: [
                    label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    label.topAnchor.constraint(equalTo: beforeLabel.bottomAnchor, constant: vSpacing),
                    // 上一行的最后一个label对其右侧进行约束
                    beforeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor)
                ])
                maxX = labelSize.width
            } else {
                // 继续在这一行
                if let beforeLabel = beforeLabel {
                    // 同一行 第 2, 3, 4...个
                    labsConstraints.append(contentsOf: [
                        label.leadingAnchor.constraint(equalTo: beforeLabel.trailingAnchor, constant: hSpacing),
                        label.topAnchor.constraint(equalTo: beforeLabel.topAnchor)
                    ])
                    maxX += labelSize.width + hSpacing
                } else {
                    // 第一行第一个
                    labsConstraints.append(contentsOf: [
                        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                        label.topAnchor.constraint(equalTo: contentView.topAnchor)
                    ])
                    maxX = labelSize.width
                }
            }
            beforeLabel = label
        }
        
        if let lastLabel = displayViews.last {
            // 加上最后一个label的底部和右侧的约束
            labsConstraints.append(contentsOf: [
                lastLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                lastLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor)
            ])
        }
        labsConstraints.activate()
    }
    
    /// 准备复用
    func prepareForReuse() {
        let labelsCount = tags.count
        let displayCount = displayViews.count
        
        /// labs数量比views数量多，添加差异
        if labelsCount > displayCount {
            let diff = labelsCount - displayCount
            for _ in 0..<diff {
                addView(dequeueReuseView())
            }
        }
        else {
            /// labels数量比views数量少，移除差异
            let diff = displayCount - labelsCount
            var rangeViews = displayViews[0..<diff]
            for _ in 0..<diff {
                let view = rangeViews.removeLast()
                appendReuseView(view)
            }
        }
        
        let reuseCount = reuseViews.count
        print("剩余复用的数量reuseCount: \(reuseCount)")
    }
    
    private func updateMyConstraints() {
        
        let inset = contentInset
        contentConstraints.forEach {
            switch $0.firstAttribute {
            case .top:
                $0.constant = inset.top
            case .bottom:
                $0.constant = inset.bottom
            case .left, .leading:
                $0.constant = inset.left
            case .right, .trailing:
                $0.constant = inset.right
            default:
                break
            }
        }
    }
}

extension LabelListView {
    /// 从复用池出列，没有则闯将
    private func dequeueReuseView() -> TagView {
        // 取出一个复用的view，复用池不够时创建新的, 添加到stackView
        // 复用池不够时创建新的，并添加到stackView
        if reuseViews.count > 0 {
            let view = reuseViews.removeLast()
            view.isHidden = false
            return view
        }
        return TagView()
    }
    
    private func addView(_ view: TagView) {
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        displayViews.append(view)
    }
    
    /// 往复用池中添加
    private func appendReuseView(_ view: TagView) {
        view.removeFromSuperview()
        view.isHidden = true
        let index = displayViews.lastIndex { tagView in
            return tagView == view
        }
        if let index = index {
            displayViews.remove(at: index)
        }
        reuseViews.append(view)
    }
}

struct WeakBox<T: AnyObject> {
    var box: T
}

class SizeObserver: NSObject {
    enum KeyPath: CaseIterable {
        case bounds(_ bounds: CGRect = .zero)
        
        var keyPath: String {
            switch self {
            case .bounds:
                return "bounds"
            }
        }
        
        static var allCases: [SizeObserver.KeyPath] {
            return [.bounds()/*, .contentSize()*/]
        }
    }
    private weak var target: UIView?
    private var eventHandler: (_ keyPath: KeyPath) -> Void
    init(target: UIView, eventHandler: @escaping (_ keyPath: KeyPath) -> Void) {
        self.eventHandler = eventHandler
        super.init()
        self.target = target
        KeyPath.allCases.forEach {
            target.addObserver(self, forKeyPath: $0.keyPath, options: [.old, .new, .initial], context: nil)
        }
        
    }
    
    deinit {
        KeyPath.allCases.forEach {
            target?.removeObserver(self, forKeyPath: $0.keyPath)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        
        KeyPath.allCases.forEach {
            switch $0 {
            case .bounds:
                let new = change?[.newKey] as? CGRect ?? .zero
                let old = change?[.oldKey] as? CGRect ?? .zero
                if keyPath == $0.keyPath, !old.size.equalTo(new.size) {
                    eventHandler(KeyPath.bounds(new))
                }
            }
        }
    }
}
