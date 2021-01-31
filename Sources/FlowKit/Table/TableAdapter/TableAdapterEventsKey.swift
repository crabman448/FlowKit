//
//  TableAdapterEventsKey.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import Foundation

internal enum TableAdapterEventsKey: Int {
    case dequeue = 0
    case canEdit
    case commitEdit
    case canMoveRow
    case moveRow
    case prefetch
    case cancelPrefetch
    case rowHeight
    case rowHeightEstimated
    case indentLevel
    case willDisplay
    case shouldSpringLoad
    case tapOnAccessory
    case willSelect
    case tap
    case willDeselect
    case didDeselect
    case willBeginEdit
    case didEndEdit
    case editStyle
    case deleteConfirmTitle
    case editShouldIndent
    case moveAdjustDestination
    case endDisplay
    case shouldShowMenu
    case canPerformMenuAction
    case performMenuAction
    case shouldHighlight
    case didHighlight
    case didUnhighlight
    case canFocus
    case leadingSwipeActions
    case trailingSwipeActions
    case contextMenuConfiguration
}
