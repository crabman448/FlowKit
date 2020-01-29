//
//  ArticleCellSizesCalculator.swift
//  ExampleApp
//
//  Created by Taras on 29/01/2020.
//  Copyright © 2020 FlowKit. All rights reserved.
//

import UIKit

class ArticleCellSizesCalculator {
    lazy var prototypeView = ArticleCellView(frame: CGRect.zeroOriginHugeValue)

    func calculateContentHeight(with title: String, fixedWidth: CGFloat) -> CGFloat {
        let prototypeModel = ArticleCellModel.prototypeModel(title: title)

        prototypeView.configure(with: prototypeModel)

        prototypeView.setNeedsLayout()
        prototypeView.layoutIfNeeded()

        let sizeToFit = CGSize(width: fixedWidth, height: .greatestFiniteMagnitude)

        let prototypeCellSize = prototypeView.systemLayoutSizeFitting(sizeToFit,
                                                                      withHorizontalFittingPriority: .required,
                                                                      verticalFittingPriority: .fittingSizeLevel)

        return prototypeCellSize.height
    }
}
