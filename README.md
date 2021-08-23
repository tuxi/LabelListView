# LabelListView

通过自动布局实现的多标签视图

### 示例

```swift
import UIKit
import LabelListView

class ExampleViewController: UIViewController {

    lazy var labelsView = LabelListView()
    
    var labels: [String] = [] {
        didSet {
            labelsView.reloadDataIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        view.addSubview(labelsView)
        labelsView.translatesAutoresizingMaskIntoConstraints = false
        labelsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        labelsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        labelsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        
        labelsView.dataSource = self
        labelsView.registerLabelClass(ofType: Label.self)
        
        labelsView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        labelsView.stackView.backgroundColor = .blue
        
        self.labels = ["今天", "明天", "我们的爱", "周杰伦", "无与伦比", "世界有你才好", "大岩姐姐", "Today at Swift", "杨孝远"]
    }

}

extension ExampleViewController: LabelListViewDataSource {
    func labelListView(_ lableListView: LabelListView, heightForRowAt index: Int) -> CGFloat {
        return 50
    }
    
    func labelListView(_ labelListView: LabelListView, labelForItemAt index: Int) -> LabelReusable {
        let label = try! labelListView.dequeueReusableLabel(ofType: Label.self, index: index)
        label.text = labels[index]
        label.layer.cornerRadius = 12.5
        label.backgroundColor = .orange
        return label
    }
    
    func numberOfItems(in labelListView: LabelListView) -> Int {
        return labels.count
    }
}
```
