//
//  HeaderFooterProtocol.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import UIKit

// MARK: HeaderFooterProtocol

public protocol HeaderFooterProtocol: AnyObject {
    static var reuseIdentifier: String { get }
}

public extension HeaderFooterProtocol {
    /// By default the identifier of the cell is the same name of the cell.
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

// MARK: UITableViewHeaderFooterView

extension UITableViewHeaderFooterView: HeaderFooterProtocol {
    
    /// By default it uses the same name of the class.
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

// MARK: UICollectionReusableView

extension UICollectionReusableView: HeaderFooterProtocol {
    
    /// By default it uses the same name of the class.
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}
