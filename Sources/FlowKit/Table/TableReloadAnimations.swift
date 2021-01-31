//
//  TableReloadAnimations.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import UIKit

public struct TableReloadAnimations: TableReloadAnimationProtocol {
    public static func `default`() -> TableReloadAnimations {
        return TableReloadAnimations()
    }
}

public protocol TableReloadAnimationProtocol {
    func animationForRow(action: TableAnimationAction) -> UITableView.RowAnimation
    func animationForSection(action: TableAnimationAction) -> UITableView.RowAnimation
}

public extension TableReloadAnimationProtocol {
    func animationForRow(action: TableAnimationAction) -> UITableView.RowAnimation {
        return .none
    }
    
    func animationForSection(action: TableAnimationAction) -> UITableView.RowAnimation {
        return .none
    }
}

public enum TableAnimationAction {
    case delete
    case insert
    case reload
}
