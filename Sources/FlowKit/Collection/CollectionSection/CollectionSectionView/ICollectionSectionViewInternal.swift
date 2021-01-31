//
//  ICollectionSectionViewInternal.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import UIKit

protocol ICollectionSectionViewInternal {
    @discardableResult
    func dispatch(_ event: CollectionSectionViewEventsKey, type: SectionViewType,  view: UICollectionReusableView?, section: Int, collection: UICollectionView) -> Any?
}
