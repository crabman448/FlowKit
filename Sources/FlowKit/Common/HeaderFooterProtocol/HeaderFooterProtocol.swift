//
//  HeaderFooterProtocol.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import UIKit

// MARK: HeaderFooterProtocol

public protocol HeaderFooterProtocol: class {
    static var reuseIdentifier: String { get }
    static var registerAsClass: Bool { get }
}

public extension HeaderFooterProtocol {
    
    /// By default the identifier of the cell is the same name of the cell.
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    /// Return true if you want to allocate the cell via class name using classic
    /// `initWithFrame`/`initWithCoder`. If your cell UI is defined inside a nib file
    /// or inside a storyboard you must return `false`.
    static var registerAsClass : Bool {
        return false
    }
}

// MARK: UITableViewHeaderFooterView

extension UITableViewHeaderFooterView: HeaderFooterProtocol {
    
    /// By default it uses the same name of the class.
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    /// Return true if you want to allocate the cell via class name using classic
    /// `initWithFrame`/`initWithCoder`. If your header/footer UI is defined inside a nib file
    /// or inside a storyboard you must return `false`.
    public static var registerAsClass: Bool {
        return false
    }
}

// MARK: UICollectionReusableView

extension UICollectionReusableView: HeaderFooterProtocol {
    
    /// By default it uses the same name of the class.
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    /// Return true if you want to allocate the cell via class name using classic
    /// `initWithFrame`/`initWithCoder`. If your header/footer UI is defined inside a nib file
    /// or inside a storyboard you must return `false`.
    public static var registerAsClass: Bool {
        return false
    }
}
