//
//  CompositionalCollectionDirector.swift
//  FlowKit
//
//  Created by Taras on 29/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import Foundation
import UIKit

open class CompositionalCollectionDirector: CollectionDirector {
    
    public let layout: UICollectionViewCompositionalLayout
    
    /// Initialize a new flow collection manager.
    /// Note: Layout of the collection must be a UICollectionViewFlowLayout or subclass.
    ///
    /// - Parameters:
    ///   - collection: collection instance to manage.
    public override init(_ collection: UICollectionView) {
        guard let layout = collection.collectionViewLayout as? UICollectionViewCompositionalLayout else {
            fatalError("Expected UICollectionViewFlowLayout")
        }
        
        self.layout = layout
        
        super.init(collection)
    }
}
