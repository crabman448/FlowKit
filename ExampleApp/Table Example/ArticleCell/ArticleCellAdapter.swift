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

        self.on.dequeue = { ctx in
            ctx.cell?.titleLabel?.text = ctx.model.title
        }

        self.on.rowHeight = { _ in
            return 100.0
        }

        self.on.rowHeightEstimated = { _ in
            return 100.0
        }
    }

}
