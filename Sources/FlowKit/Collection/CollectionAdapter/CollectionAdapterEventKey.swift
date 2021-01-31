//
//  CollectionAdapterEventKey.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import Foundation

internal enum CollectionAdapterEventKey: Int {
    case dequeue
    case shouldSelect
    case shouldDeselect
    case didSelect
    case didDeselect
    case didHighlight
    case didUnhighlight
    case shouldHighlight
    case willDisplay
    case endDisplay
    case shouldShowEditMenu
    case canPerformEditAction
    case performEditAction
    case canFocus
    case itemSize
    //case generateDragPreview
    //case generateDropPreview
    case prefetch
    case cancelPrefetch
    case shouldSpringLoad
    case contextMenuConfiguration
}
