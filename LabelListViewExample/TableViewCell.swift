//
//  TableViewCell.swift
//  LabelListViewExample
//
//  Created by xiaoyuan on 2021/8/20.
//

import UIKit
import LabelListView

class TableViewCell: UITableViewCell {

    lazy var labelsView = LabelListView()
    
    var labels: [String] = [] {
        didSet {
            labelsView.reloadDataIfNeeded()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(labelsView)
        labelsView.translatesAutoresizingMaskIntoConstraints = false
        labelsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        labelsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        labelsView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        labelsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        labelsView.dataSource = self
        labelsView.registerLabelClass(ofType: Label.self)
        
        labelsView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        labelsView.stackView.backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension TableViewCell: LabelListViewDataSource {
    func labelListView(_ labelListView: LabelListView, labelForItemAt index: Int) -> LabelReusable {
        let label = try! labelListView.dequeueReusableLabel(ofType: Label.self, index: index)
        label.text = labels[index]
        label.layer.cornerRadius = 12.5
        label.backgroundColor = .orange
        label.clipsToBounds = true
        label.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        if index % 2 == 0 {
            label.backgroundColor = .red
        }
        return label
    }
    
    func numberOfItems(in labelListView: LabelListView) -> Int {
        return labels.count
    }
    
//    func labelListView(_ lableListView: LabelListView, heightForRowAt index: Int) -> CGFloat {
//        return 50
//    }
}
