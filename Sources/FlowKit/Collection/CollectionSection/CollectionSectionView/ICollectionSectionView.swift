//
//  ICollectionSectionView.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import Foundation

public protocol ICollectionSectionView: AbstractSectionViewProtocol {
    var section: CollectionSection? { get set }
}
