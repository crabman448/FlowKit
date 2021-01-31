//
//  InternalContext.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import UIKit

struct InternalContext {
    var model: ModelProtocol?
    var models: [ModelProtocol]?
    var path: IndexPath?
    var paths: [IndexPath]?
    var cell: CellProtocol?
    var container: Any
    var param1: Any?
    var param2: Any?
    var param3: Any?

    init(_ model: ModelProtocol?, _ path: IndexPath, _ cell: CellProtocol?, _ scrollview: UIScrollView, param1: Any? = nil, param2: Any? = nil, param3: Any? = nil) {
        self.model = model
        self.path = path
        self.cell = cell
        self.container = scrollview
        self.param1 = param1
        self.param2 = param2
    }
    
    init(_ models: [ModelProtocol], _ paths: [IndexPath], _ scrollview: UIScrollView) {
        self.models = models
        self.paths = paths
        self.container = scrollview
    }
}
