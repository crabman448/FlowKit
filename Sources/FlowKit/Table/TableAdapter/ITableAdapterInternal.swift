//
//  ITableAdapterInternal.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import UIKit

protocol ITableAdapterInternal {
    
    @discardableResult
    func dispatch(_ event: TableAdapterEventsKey,  context: InternalContext) -> Any?

    func _instanceCell(in table: UITableView, at indexPath: IndexPath?) -> UITableViewCell
}
