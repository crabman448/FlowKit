//
//  ITableSectionViewInternal.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import UIKit

protocol ITableSectionViewInternal  {
    @discardableResult
    func dispatch(_ event: TableSectionViewEventsKey, type: SectionType, view: UIView?, section: Int, table: UITableView) -> Any?
}
