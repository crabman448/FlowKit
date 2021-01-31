//
//  AbstractAdapterProtocol.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import Foundation

public protocol AbstractAdapterProtocol {
    var modelType: Any.Type { get }
    var cellType: Any.Type { get }
    var cellReuseIdentifier: String { get }
    var cellClass: AnyClass { get }
    var registerAsClass: Bool { get }
}
