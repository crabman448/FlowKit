//
//  CollectionAdapterProtocolFunctions.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import UIKit

internal protocol CollectionAdapterProtocolFunctions {

    @discardableResult
    func dispatch(_ event: CollectionAdapterEventKey, context: InternalContext) -> Any?
    
    func _instanceCell(in collection: UICollectionView, at indexPath: IndexPath?) -> UICollectionViewCell
}
