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
            updateContentConstraints()
        }
    }
    
    /// 最大行数
    public var numberOfRows: Int = 0 {
        didSet {
            guard numberOfRows != oldValue else {
                return
            }
            setNeedsUpdateConstraints()
        }
    }
    
    /// 截断令牌，当超出最大行数时，为截断的部分标签添加的控件，需有宽高
    public var truncationToken: UIView? {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    /// 最大宽度
    public var maxWidthOfItem: CGFloat?
    
    /// 在显示的标签
    private var displayViews = [LabelReusable]()
    /// 准备复用的标签
    private var reuseViews = [LabelReusable]()
    /// 每行的标签
    private var rows = [[LabelReusable]]()
    /// 当content的size改变时，重新布局，以填充标签
    private var sizeObserver: WeakBox<SizeObserver>?
    
    private var contentConstraints = [NSLayoutConstraint]()
    private var labsConstraints = [NSLayoutConstraint]()
    
    private var identifiers = [String: AnyClass]()
    
    private var needsUpdateConstraints = true
    private var lastContentWidth: CGFloat?
    
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
        
        updateContentConstraints()
        
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
        if !needsUpdateConstraints && lastContentWidth == contentWidth {
            return
        }
        
        lastContentWidth = contentWidth
        /// 记录最后一个item
        var lastLabelOfLastRow: UIView?
        
        contentView.removeConstraints(labsConstraints)
        labsConstraints.removeAll()
        
        /// 更新约束
        for (rowIndex, row) in rows.enumerated() {
            guard let firstLabel = row.first, let lastLabel = row.last else {
                continue
            }
            // 每一行的第一个设置左侧间距
            labsConstraints.append(contentsOf: [
                firstLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
            ])
            // 每一行的最后一个设置右侧间距
            labsConstraints.append(contentsOf: [
                lastLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            ])
            
            if let lastLabelOfLastRow = lastLabelOfLastRow {
                // 其他行
                labsConstraints.append(contentsOf: [
                    firstLabel.topAnchor.constraint(equalTo: lastLabelOfLastRow.bottomAnchor, constant: vSpacing),
                ])
            }
            else {
                // 第一行
                labsConstraints.append(contentsOf: [
                    firstLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
                ])
            }
            
            // 获取行高
            let rowHeight = dataSource!.labelListView(self, heightForRowAt: rowIndex)
            var previous: LabelReusable?
            for label in row {
                if rowHeight > 0 {
                    // 为每一个label 添加行高
                    labsConstraints.append(
                        label.heightAnchor.constraint(equalToConstant: rowHeight)
                    )
                }
                
                if let previous = previous {
                    // 同一行 第 2, 3, 4...个
                    labsConstraints.append(contentsOf: [
                        label.leadingAnchor.constraint(equalTo: previous.trailingAnchor, constant: hSpacing),
                        label.topAnchor.constraint(equalTo: firstLabel.topAnchor),
                        label.heightAnchor.constraint(equalTo: previous.heightAnchor)
                    ])
                }
                
                previous = label
            }
            
            lastLabelOfLastRow = lastLabel
        }
        
        if let lastLabel = rows.last?.last {
            // 加上最后一个label的底部和右侧的约束
            labsConstraints.append(contentsOf: [
                lastLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
            
            if let truncationToken = truncationToken, truncationToken.isHidden == false {
                contentView.addSubview(truncationToken)
                truncationToken.translatesAutoresizingMaskIntoConstraints = false
                contentView.removeConstraints(truncationToken.constraints)
                truncationToken.leadingAnchor.constraint(equalTo: lastLabel.trailingAnchor, constant: hSpacing).isActive = true
                truncationToken.centerYAnchor.constraint(equalTo: lastLabel.centerYAnchor).isActive = true
            }
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
        truncationToken?.isHidden = true
        let diff = labelsCount - displayCount
        let lastRowCount = rows.count
        rows = remakeRows()
        let rowCount = rows.count
        /// 判断行数是否发生改变
        needsUpdateConstraints = (diff != 0 || rowCount != lastRowCount)
        let reuseCount = reuseViews.count
        print("待复用的数量reuseCount: \(reuseCount)")
    }
    
    /// 计算总行数
    private func remakeRows() -> [[LabelReusable]] {
        let contentWidth = self.stackView.frame.size.width
        if contentWidth <= 0 {
            return []
        }
        let count = dataSource!.numberOfItems(in: self)
        /// 记录最后一个item
        var lastLabel: UIView?
        // 累计宽度
        var maxX: CGFloat = 0
        var rows = [[LabelReusable]]()
        var row = [LabelReusable]()
        var rowIndex = 0
        for index in 0..<count {
            let label = displayViews[index]
            let labelSize = label.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
            if lastLabel != nil, (maxX + labelSize.width + hSpacing) > contentWidth {
                // 添加上一行
                rows.append(row)
                // 换到下一行的第一个
                rowIndex += 1
                row = [LabelReusable]()
                if numberOfRows > 0, rowIndex > numberOfRows - 1 {
                    onRowsTruncation(rows: &rows)
                    break
                }
                maxX = labelSize.width
                row.append(label)
            } else {
                row.append(label)
                // 继续在这一行
                if lastLabel != nil {
                    // 同一行 第 2, 3, 4...个
                    maxX += labelSize.width + hSpacing
                } else {
                    // 第一行第一个
                    maxX = labelSize.width
                }
            }
            lastLabel = label
            contentView.addSubview(label)
        }
        // 添加最后一行
        if row.count > 0 {
            rows.append(row)
        }
        print("总行数: \(rows.count)")
        return rows
    }
    
    /// 当发生截断时，重置最后一行
    private func onRowsTruncation(rows: inout [[LabelReusable]]) {
        guard let truncationToken = truncationToken, let lastRow = rows.last else {
            return
        }
        var contentWidth = self.stackView.frame.size.width
        truncationToken.isHidden = false
        let truncationTokenSize = truncationToken.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        contentWidth -= (truncationTokenSize.width - hSpacing)
        var row = [LabelReusable]()
        var maxX: CGFloat = 0
        lastRow.forEach { label in
            label.removeFromSuperview()
        }
        for index in 0..<lastRow.count {
            let label = lastRow[index]
            let labelSize = label.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
            if (maxX + labelSize.width + hSpacing) > contentWidth {
                break
            }
            row.append(label)
            contentView.addSubview(label)
            maxX += labelSize.width + hSpacing
        }
        rows.removeLast()
        rows.append(row)
    }
    
    private func updateContentConstraints() {
        
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
