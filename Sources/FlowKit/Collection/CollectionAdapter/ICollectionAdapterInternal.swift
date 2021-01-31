//
//  ICollectionAdapterInternal.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import UIKit

protocol ICollectionAdapterInternal {

    @discardableResult
    func dispatch(_ event: CollectionAdapterEventKey, context: InternalContext) -> Any?
    
    func _instanceCell(in collection: UICollectionView, at indexPath: IndexPath?) -> UICollectionViewCell
}
