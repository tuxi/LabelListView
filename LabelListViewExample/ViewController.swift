//
//  ViewController.swift
//  LabelListViewExample
//
//  Created by xiaoyuan on 2021/8/19.
//

import UIKit
import LabelListView

class ViewController: UIViewController {
    
    lazy var tagsView = LabelListView()
    
    var labels = ["今天", "明天", "我们的爱", "周杰伦", "无与伦比", "世界有你才好", "大岩姐姐", "Today at Swift", "杨孝远"]
    
    private var flag = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagsView.dataSource = self
        tagsView.registerLabelClass(ofType: Label.self)
        
        view.addSubview(tagsView)
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        tagsView.backgroundColor = .blue
        
        ["H:|-30-[view]-30-|", "V:|-100-[view]"].flatMap {
            NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: ["view": tagsView])
        }
        .activate()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if flag {
            labels = ["今天", "明天", "我们的爱", "周杰伦", "无与伦比", "世界有你才好", "大岩姐姐", "Today at Swift", "杨孝远"]
            tagsView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 50)
        }
        else {
            labels = ["也可以的李静啊可是大事", "在大撒上大", "添加到大撒实打实的", "父视图萨达", "之后", "设置撒打算大", "数据啊山东科技拉升的李静啊可是大事的李静啊可是大事"]
            
            tagsView.contentInset = UIEdgeInsets(top: 60, left: 100, bottom: 10, right: 10)
        }
        tagsView.reloadData()
        flag = !flag
    }

}

extension ViewController: LabelListViewDataSource {
    
    func labelListView(_ labelListView: LabelListView, labelForItemAt index: Int) -> LabelReusable {
        let label = try! labelListView.dequeueReusableLabel(ofType: Label.self, index: index)
        label.text = labels[index] + "\(index)"
        label.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return label
    }
    
    func numberOfItems(in labelListView: LabelListView) -> Int {
        labels.count
    }
}
