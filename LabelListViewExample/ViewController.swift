//
//  ViewController.swift
//  LabelListViewExample
//
//  Created by xiaoyuan on 2021/8/19.
//

import UIKit
import LabelListView

class ViewController: UITableViewController {
    
    var models = [
//        ["今天"],
        ["今天", "明天", "我们的爱", "周杰伦", "无与伦比", "世界有你才好", "大岩姐姐", "Today at Swift", "杨孝远"],
        ["也可以的李静啊可是大事", "在大撒上大", "添加到大撒实打实的", "父视图萨达", "之后", "设置撒打算大", "数据啊山东科技拉升的李静啊可是大事的李静啊可是大事"],
        ["今天", "明天", "我们的爱", "周杰伦", "无与伦比", "世界有你才好", "大岩姐姐", "Today at Swift", "杨孝远"],
        ["今天", "明天", "我们的爱", "周杰伦", "无与伦比", "世界有你才好", "大岩姐姐", "Today at Swift", "杨孝远"],
        ["也可以的李静啊可是大事", "在大撒上大", "添加到大撒实打实的", "父视图萨达", "之后", "设置撒打算大", "数据啊山东科技拉升的李静啊可是大事的李静啊可是大事"],
        ["今天", "明天", "我们的爱", "周杰伦", "无与伦比", "世界有你才好", "大岩姐姐", "Today at Swift", "杨孝远"],
        ["今天", "明天", "我们的爱", "周杰伦", "无与伦比", "世界有你才好", "大岩姐姐", "Today at Swift", "杨孝远"],
        ["也可以的李静啊可是大事", "在大撒上大", "添加到大撒实打实的", "父视图萨达", "之后", "设置撒打算大", "数据啊山东科技拉升的李静啊可是大事的李静啊可是大事"],
        ["今天", "明天", "我们的爱", "周杰伦", "无与伦比", "世界有你才好", "大岩姐姐", "Today at Swift", "杨孝远"]
    ]

    var heights: [CGFloat] = []
    
//    lazy var cell: TableViewCell = {
//        let cell = TableViewCell(style: .default, reuseIdentifier: "TableViewCell1")
//        cell.contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).with(priority: 1000).isActive = true
//        return cell
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heights = models.map { _ in 0 }
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        
        self.title = "标签列表"
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.labels = models[indexPath.row]
        return cell
    }
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        if heights[indexPath.row] == 0 {
//            cell.labels = models[indexPath.row]
//            let size = cell.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
//            heights[indexPath.row] = size.height
//        }
//        return heights[indexPath.row]
//    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 150
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = ExampleViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
