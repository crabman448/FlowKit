// 
//  ArticleCellModel.swift
//  ExampleApp
//
//  Created by Taras on 29/01/2020.
//  Copyright © 2020 FlowKit. All rights reserved.
//

import UIKit

struct ArticleCellModel: ModelProtocol {
    let title: String
    let contentHeight: CGFloat

    init(title: String, contentHeight: CGFloat) {
        self.title = title
        self.contentHeight = contentHeight
    }

    // MARK: - Stub model

    static func prototypeModel(title: String) -> ArticleCellModel {
        return ArticleCellModel(title: title, contentHeight: 0.0)
    }

    // MARK: - ModelProtocol

    var modelId: String {
        return title
    }
}
