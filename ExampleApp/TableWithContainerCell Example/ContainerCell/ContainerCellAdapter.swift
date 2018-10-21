//
//  ContainerCellAdapter.swift
//  ExampleApp
//
//  Created by Taras Nikulin on 21.10.2018.
//  Copyright © 2018 FlowKit. All rights reserved.
//

import Foundation

class ContainerCellAdapter: TableAdapter<ContainerCellModel, ContainerCell> {
    init() {
        super.init()

        on.dequeue = { context in
            context.cell?.containedView = context.model.view
            context.cell?.willDisplay()
        }

//        on.willDisplay = { context in
//            context.cell?.willDisplay()
//        }
    }
}
