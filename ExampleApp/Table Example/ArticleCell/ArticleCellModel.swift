// 
//  ArticleCellModel.swift
//  ExampleApp
//
//  Created by Taras on 29/01/2020.
//  Copyright © 2020 FlowKit. All rights reserved.
//

import UIKit

public struct ArticleCellModel: ModelProtocol {
    public let title: String

    public let contentHeight: CGFloat = 100.0

    public init(title: String) {
        self.title = title
    }

    // MARK: - ModelProtocol

    public var modelId: String {
        return title
    }
}
