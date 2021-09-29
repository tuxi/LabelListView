//
//  ExampleViewController.swift
//  LabelListViewExample
//
//  Created by xiaoyuan on 2021/8/20.
//

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
        labelsView.numberOfRows = 2
        let btn = UIButton()
        btn.setTitle("展开", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .purple
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        labelsView.truncationToken = btn
        btn.addTarget(self, action: #selector(openAction), for: .touchUpInside)
        
        labelsView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        labelsView.stackView.backgroundColor = .blue
        
        self.labels = ["也可以的李静啊可是大事", "在大撒上大", "添加到大撒实打实的", "父视图萨达", "之后", "设置撒打算大", "数据啊山东科技拉升的李静啊可是大事的李静啊可是大事"]
        //["今天", "明天", "我们的爱", "周杰伦", "无与伦比", "世界有你才好", "大岩姐姐", "Today at Swift", "杨孝远"]
    }

    @objc private func openAction() {
        labelsView.numberOfRows = 0
    }
}

extension ExampleViewController: LabelListViewDataSource {
    func labelListView(_ lableListView: LabelListView, heightForRowAt index: Int) -> CGFloat {
        if index == 2 {
            return 50
        }
        return 100
    }
    
    func labelListView(_ labelListView: LabelListView, labelForItemAt index: Int) -> LabelReusable {
        let label = try! labelListView.dequeueReusableLabel(ofType: Label.self, index: index)
        label.text = labels[index]
        label.layer.cornerRadius = 15
        label.backgroundColor = .orange
        label.layer.masksToBounds = true
        label.contentInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return label
    }
    
    func numberOfItems(in labelListView: LabelListView) -> Int {
        return labels.count
    }
}
