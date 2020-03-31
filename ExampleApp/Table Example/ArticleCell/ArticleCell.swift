// 
//  ArticleCell.swift
//  ExampleApp
//
//  Created by Taras on 29/01/2020.
//  Copyright © 2020 FlowKit. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    let articleCellView = ArticleCellView()

    // MARK: - Init

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    // MARK: Setup

    func setup() {
        self.contentView.constraint(subview: articleCellView, to: .superview)
    }

    // MARK: - Configuration

    func configure(with model: ArticleCellModel) {
        articleCellView.configure(with: model)
    }
}
