//
//  CellProtocol.swift
//  FlowKit-iOS
//
//  Created by Taras on 31/03/2020.
//  Copyright © 2020 FlowKit. All rights reserved.
//

import UIKit

extension UICollectionViewCell: CellProtocol { }

extension UITableViewCell: CellProtocol { }

protocol CellProtocol: class {
    static var reuseIdentifier: String { get }
}

extension CellProtocol {
    /// The identifier of the cell is the same name of the cell.
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
