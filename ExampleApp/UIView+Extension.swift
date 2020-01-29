//
//  UIView+Extension.swift
//  ExampleApp
//
//  Created by Taras on 29/01/2020.
//  Copyright © 2020 FlowKit. All rights reserved.
//

import UIKit

public extension UIView {
    // MARK: Adding subviews

    enum ConstraintsDestination {
        case superview
        case safeArea
    }

    func constraint(subview: UIView, to destination: ConstraintsDestination, insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        subview.translatesAutoresizingMaskIntoConstraints = false

        subview.removeFromSuperview()
        self.addSubview(subview)

        let leadingAnchor: NSLayoutXAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        let topAnchor: NSLayoutYAxisAnchor
        let bottomAnchor: NSLayoutYAxisAnchor

        switch destination {
        case .superview:
            leadingAnchor = self.leadingAnchor
            trailingAnchor = self.trailingAnchor
            topAnchor = self.topAnchor
            bottomAnchor = self.bottomAnchor
        case .safeArea:
            leadingAnchor = self.safeAreaLayoutGuide.leadingAnchor
            trailingAnchor = self.safeAreaLayoutGuide.trailingAnchor
            topAnchor = self.safeAreaLayoutGuide.topAnchor
            bottomAnchor = self.safeAreaLayoutGuide.bottomAnchor
        }

        subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left).isActive = true
        trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: insets.right).isActive = true
        subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
        bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: insets.bottom).isActive = true
    }
}
