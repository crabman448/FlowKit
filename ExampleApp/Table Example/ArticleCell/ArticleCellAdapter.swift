// 
//  ArticleCellAdapter.swift
//  ExampleApp
//
//  Created by Taras on 29/01/2020.
//  Copyright © 2020 FlowKit. All rights reserved.
//

import UIKit

class ArticleCellAdapter: TableAdapter<ArticleCellModel, ArticleCell> {
    init() {
        super.init()

        self.on.dequeue = { context in
            context.cell?.configure(with: context.model)
        }

        self.on.rowHeight = { context in
            return context.model.contentHeight
        }

        self.on.rowHeightEstimated = { context in
            return context.model.contentHeight
        }
    }
}
