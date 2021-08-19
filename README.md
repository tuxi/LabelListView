# LabelListView

通过自动布局实现的多标签视图

### 示例

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    lazy var tagsView = LabelListView<Label>()
    view.addSubview(tagsView)
    tagsView.translatesAutoresizingMaskIntoConstraints = false
    tagsView.backgroundColor = .blue
    
    ["H:|-30-[view]-30-|", "V:|-100-[view]"].flatMap {
        NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: ["view": tagsView])
    }
    .activate()
    
    tagsView.tags = ["也可以", "在大撒上大", "添加到大撒实打实的", "父视图萨达", "之后", "设置撒打算大", "数据啊山东科技拉升"]
}
```
