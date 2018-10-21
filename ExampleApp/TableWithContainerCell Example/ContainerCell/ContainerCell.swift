//
//  ContainerCell.swift
//  ExampleApp
//
//  Created by Taras Nikulin on 21.10.2018.
//  Copyright © 2018 FlowKit. All rights reserved.
//

import UIKit

final class ContainerCell: UITableViewCell {
    var containedView: UIView?

    override func prepareForReuse() {
        super.prepareForReuse()

        containedView?.removeFromSuperview()
        containedView = nil
    }

    func willDisplay() {
        guard let containedView = containedView else { return }

        containedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containedView)
        if #available(iOS 9.0, *) {
            contentView.addConstraints([
                containedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                containedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                containedView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
                containedView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
                ])
        }
    }
}
