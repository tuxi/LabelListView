//
//  Label.swift
//  LabelListView
//
//  Created by xiaoyuan on 2021/8/19.
//

import UIKit
import LabelListView

open class Label: UILabel {

    /// 设置文本的内边距
   open var contentInset = UIEdgeInsets.zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}

extension Label {
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: contentInset)
        let textRect = super.textRect(forBounds: insetRect,
                                      limitedToNumberOfLines: numberOfLines
        )
        let invertedInsets = UIEdgeInsets(top: -contentInset.top,
                                          left: -contentInset.left,
                                          bottom: -contentInset.bottom,
                                          right: -contentInset.right
        )
        return textRect.inset(by: invertedInsets)
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInset))
    }
}

extension Label: LabelReusable {
    public static var reuseIdentifier: String {
        return "label"
    }
}
