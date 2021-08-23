//
//  NSLayoutConstraint+Extensions.swift
//  DigitalCommunity
//
//  Created by xiaoyuan on 2021/7/5.
//

import UIKit

public extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
    func with(priority: Float) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(priority)
        return self
    }
}

extension Array where Element: NSLayoutConstraint {
    @discardableResult
    public func activate() -> Self {
        NSLayoutConstraint.activate(self)
        return self
    }
    @discardableResult
    public func deactivate() -> Self {
        NSLayoutConstraint.deactivate(self)
        return self
    }
}
