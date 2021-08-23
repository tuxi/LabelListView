//
//  LabelListView.swift
//  LabelListView
//
//  Created by xiaoyuan on 2021/8/19.
//

import UIKit

public protocol LabelReusable: UIView {
    static var reuseIdentifier: String { get }
}

public protocol LabelListViewDataSource: AnyObject {
    func labelListView(_ labelListView: LabelListView, labelForItemAt index: Int) -> LabelReusable
    func numberOfItems(in labelListView: LabelListView) -> Int
    func labelListView(_ lableListView: LabelListView, heightForRowAt index: Int ) -> CGFloat
}

extension LabelListViewDataSource {
   public func labelListView(_ lableListView: LabelListView, heightForRowAt index: Int ) -> CGFloat {
        return -1
    }
}

/// 一个可复用的自动换行的标签视图（使用自动布局，无需设置高度）
public class LabelListView: UIView {
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
    
    /// 总行数，根据item的布局后的数据计算
    public private(set) var numberOfRows: Int = 0
    
    /// 在显示的标签
    private var displayViews = [LabelReusable]()
    /// 准备复用的标签
    private var reuseViews = [LabelReusable]()
    /// 当content的size改变时，重新布局，以填充标签
    private var sizeObserver: WeakBox<SizeObserver>?
    
    private var contentConstraints = [NSLayoutConstraint]()
    private var labsConstraints = [NSLayoutConstraint]()
    
    private var identifiers = [String: AnyClass]()
    
    private var needsUpdateConstraints = true
    
    public weak var dataSource: LabelListViewDataSource? {
        didSet {
            reloadData()
        }
    }

    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    public lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
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
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentConstraints = ["H:|[stackView]|", "V:|[stackView]|"].flatMap {
            NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: ["stackView": stackView])
        }
        .activate()
        
        stackView.addArrangedSubview(contentView)
        
        updateMyConstraints()
        
        sizeObserver = WeakBox(box: SizeObserver(target: self.stackView, eventHandler: { [weak self] kayPath in
            self?.reloadData()
        }))
    }
    
    /// 立即刷新数据，并立即布局，适用于数据改变立即更新布局的
    public func reloadDataIfNeeded() {
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    /// 标记需要刷新，不会立即执行
    public func reloadData() {
        setNeedsUpdateConstraints()
        setNeedsLayout()
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        let contentWidth = self.stackView.frame.size.width
        if contentWidth <= 0 {
            return
        }
        
        prepareForReuse()
        
        if !needsUpdateConstraints {
            return
        }
        
        // 累计宽度
        var maxX: CGFloat = 0
        /// 每一行的第一个item
        var firstLabelOfRow: UIView?
        /// 记录最后一个item
        var lastLabel: UIView?
        
        contentView.removeConstraints(labsConstraints)
        labsConstraints.removeAll()
        
        /// 更新约束
        let count = dataSource!.numberOfItems(in: self)
       
        var rowIndex = 0
        for index in 0..<count {
            let label = displayViews[index]
            
            let labelSize = label.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
            if let lastLabel = lastLabel, (maxX + labelSize.width + hSpacing) > contentWidth, let firstLabel = firstLabelOfRow {
                // 换到下一行的第一个
                rowIndex += 1
                if let rowHeight = dataSource?.labelListView(self, heightForRowAt: rowIndex), rowHeight > 0 {
                    labsConstraints.append(
                        label.heightAnchor.constraint(equalToConstant: rowHeight)
                    )
                }
                else {
                    labsConstraints.append(
                        label.heightAnchor.constraint(equalTo: firstLabel.heightAnchor)
                    )
                }
                
                labsConstraints.append(contentsOf: [
                    label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    label.topAnchor.constraint(equalTo: firstLabel.bottomAnchor, constant: vSpacing),
                    // 上一行的最后一个label对其右侧进行约束
                    lastLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
                ])
                maxX = labelSize.width
                firstLabelOfRow = label
            } else {
                // 继续在这一行
                if let lastLabel = lastLabel, let firstLabel = firstLabelOfRow {
                    // 同一行 第 2, 3, 4...个
                    labsConstraints.append(contentsOf: [
                        label.leadingAnchor.constraint(equalTo: lastLabel.trailingAnchor, constant: hSpacing),
                        label.topAnchor.constraint(equalTo: firstLabel.topAnchor),
                        label.heightAnchor.constraint(equalTo: lastLabel.heightAnchor)
                    ])
                    maxX += labelSize.width + hSpacing
                } else {
                    // 第一行第一个
                    if let rowHeight = dataSource?.labelListView(self, heightForRowAt: rowIndex), rowHeight > 0 {
                        labsConstraints.append(
                            label.heightAnchor.constraint(equalToConstant: rowHeight)
                        )
                    }
                    labsConstraints.append(contentsOf: [
                        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                        label.topAnchor.constraint(equalTo: contentView.topAnchor)
                    ])
                    maxX = labelSize.width
                    firstLabelOfRow = label
                }
            }
            lastLabel = label
        }
        
        if count > 0 {
            self.numberOfRows = rowIndex + 1
        }
        else {
            self.numberOfRows = 0
        }
        print("总行数: \(self.numberOfRows)")
        
        if let lastLabel = displayViews.last {
            // 加上最后一个label的底部和右侧的约束
            labsConstraints.append(contentsOf: [
                lastLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                lastLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor)
            ])
        }
        else {
            // 无内容时，让contentView 压缩为zero，以适应父视图的高度
            labsConstraints.append(contentsOf: [
                contentView.heightAnchor.constraint(equalToConstant: 0)
            ])
        }
        contentView.addConstraints(labsConstraints)
    }
    
    /// 准备复用
    func prepareForReuse() {
        let labelsCount = dataSource!.numberOfItems(in: self)
        let displayCount = displayViews.count
        
        /// labels数量比views数量少，移除差异，并加入复用池
        if labelsCount < displayCount {
            let diff = displayCount - labelsCount
            var rangeViews = displayViews[0..<diff]
            for _ in 0..<diff {
                let view = rangeViews.removeLast()
                appendReuseView(view)
            }
        }

        for index in 0..<labelsCount {
            let label = dataSource!.labelListView(self, labelForItemAt: index)
            addView(label)
        }
        
        let diff = labelsCount - displayCount
        let rowCount = getRowCount()
        needsUpdateConstraints = (diff != 0 || rowCount != self.numberOfRows)
        let reuseCount = reuseViews.count
        print("待复用的数量reuseCount: \(reuseCount)")
    }
    
    /// 计算总行数
    private func getRowCount() -> Int {
        let contentWidth = self.stackView.frame.size.width
        if contentWidth <= 0 {
            return 0
        }
        let count = dataSource!.numberOfItems(in: self)
        /// 记录最后一个item
        var lastLabel: UIView?
        // 累计宽度
        var maxX: CGFloat = 0
        var rowIndex = 0
        for index in 0..<count {
            let label = displayViews[index]
            
            let labelSize = label.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
            if let lastLabel = lastLabel, (maxX + labelSize.width + hSpacing) > contentWidth {
                // 换到下一行的第一个
                rowIndex += 1
                maxX = labelSize.width
            } else {
                // 继续在这一行
                if let lastLabel = lastLabel {
                    // 同一行 第 2, 3, 4...个
                    maxX += labelSize.width + hSpacing
                } else {
                    // 第一行第一个
                    maxX = labelSize.width
                }
            }
            lastLabel = label
        }
        
        if count > 0 {
            return rowIndex + 1
        }
        else {
            return 0
        }
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

public extension LabelListView {
    func registerLabelClass<T>(ofType type: T.Type) where T: LabelReusable {
        self.identifiers[T.reuseIdentifier] = type.self
    }
}

extension LabelListView {
    /// 根据index查找一个标签视图，没有则创建
   public func dequeueReusableLabel<T>(ofType type: T.Type, index: Int) throws -> T where T: LabelReusable {
        return try dequeueReusableLabel(withIdentifier: T.reuseIdentifier, index: index) as! T
    }
    private func dequeueReusableLabel(withIdentifier identifier: String, index: Int) throws -> LabelReusable {
        
        if index < displayViews.count {
            let label = displayViews[index]
            return label
        }
        
        // 取出一个复用的view，复用池不够时创建新的, 添加到stackView
        // 复用池不够时创建新的，并添加到stackView
        if reuseViews.count > 0 {
            let view = reuseViews.removeLast()
            view.isHidden = false
            return view
        }
        guard let clas = self.identifiers[identifier] else {
            throw LabelListViewError.noRegisterLabel(identifier: identifier)
        }
        guard let viewClass = clas as? LabelReusable.Type else {
            throw LabelListViewError.notSubclassOfUIView(identifier: identifier)
        }
        return viewClass.init()
    }
    
    private func addView(_ view: LabelReusable) {
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let index = displayViews.lastIndex { tagView in
            return tagView == view
        }
        if index == nil {
            displayViews.append(view)
        }
    }
    
    /// 往复用池中添加
    private func appendReuseView(_ view: LabelReusable) {
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

public enum LabelListViewError: Error {
    case noRegisterLabel(identifier: String)
    case notSubclassOfUIView(identifier: String)
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
                // 宽度改变时回调
                if keyPath == $0.keyPath, old.size.width != new.size.width {
                    eventHandler(KeyPath.bounds(new))
                }
            }
        }
    }
}
