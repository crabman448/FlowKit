//
//  ContainerCellModel.swift
//  ExampleApp
//
//  Created by Taras Nikulin on 21.10.2018.
//  Copyright © 2018 FlowKit. All rights reserved.
//

import UIKit

struct ContainerCellModel: ModelProtocol {
    let uuid = UUID().hashValue

    var modelID: Int { return uuid }

    let view: UIView

    init(view: UIView) {
        self.view = view
    }
}
