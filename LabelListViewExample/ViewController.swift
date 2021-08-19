//
//  ViewController.swift
//  LabelListViewExample
//
//  Created by xiaoyuan on 2021/8/19.
//

import UIKit
import LabelListView

class ViewController: UIViewController {
    
    lazy var tagsView = LabelListView<Label>()
    
    private var flag = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tagsView)
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        tagsView.backgroundColor = .blue
        
        ["H:|-30-[view]-30-|", "V:|-100-[view]"].flatMap {
            NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: ["view": tagsView])
        }
        .activate()
        
        tagsView.tags = ["也可以", "在大撒上大", "添加到大撒实打实的", "父视图萨达", "之后", "设置撒打算大", "数据啊山东科技拉升"]
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if flag {
            tagsView.tags = ["标签1", "标签2", "的李静啊可是大事", "打算", "大三大四的", "阿达大厦", "数据啊山东科技拉升", "添加到大撒实打实的", "父视图萨达", "之后", "设置撒打算大", "数据啊山东科技拉升nbmbmnbmnbmnbmnbmnbmbmnbmnbm", "asda"]
            tagsView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 50)
        }
        else {
            tagsView.tags = ["也可以的李静啊可是大事", "在大撒上大", "添加到大撒实打实的", "父视图萨达", "之后", "设置撒打算大", "数据啊山东科技拉升的李静啊可是大事的李静啊可是大事"]
            
            tagsView.contentInset = UIEdgeInsets(top: 60, left: 100, bottom: 10, right: 10)
        }
        
        flag = !flag
    }

}

