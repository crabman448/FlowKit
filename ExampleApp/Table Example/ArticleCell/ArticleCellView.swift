//
//  ArticleCellView.swift
//  ExampleApp
//
//  Created by Taras on 29/01/2020.
//  Copyright © 2020 FlowKit. All rights reserved.
//

import UIKit

class ArticleCellView: UIView {
    let titleLabel = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    func commonInit() {
        constraint(subview: titleLabel, to: .superview, insets: UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0))
        setup()
    }

    // MARK: - Setup

    func setup() {
        titleLabel.numberOfLines = 0
    }

    // MARK: - Configuration

    func configure(with model: ArticleCellModel) {
        titleLabel.text = model.title
    }
}
