//
//  ModelProtocol.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import Foundation

public protocol ModelProtocol {
    
    /// Implementation of the protocol require the presence of id property which is used
    /// to uniquely identify an model. This is used by the DeepDiff library to evaluate
    /// what cells are removed/moved or deleted from table/collection and provide the right
    /// animation without an explicitly animation set.
    var modelId: String { get }
    
}
