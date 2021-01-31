//
//  ScrollViewEvents.swift
//  FlowKit
//
//  Created by Taras on 31/01/2021.
//  Copyright © 2021 FlowKit. All rights reserved.
//

import UIKit

public struct ScrollViewEvents {
    public var didScroll: ((UIScrollView) -> Void)? = nil
    public var willBeginDragging: ((UIScrollView) -> Void)? = nil
    public var willEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetOffset: UnsafeMutablePointer<CGPoint>) -> Void)? = nil
    public var endDragging: ((_ scrollView: UIScrollView, _ willDecelerate: Bool) -> Void)? = nil
    public var shouldScrollToTop: ((UIScrollView) -> Bool)? = nil
    public var didScrollToTop: ((UIScrollView) -> Void)? = nil
    public var willBeginDecelerating: ((UIScrollView) -> Void)? = nil
    public var endDecelerating: ((UIScrollView) -> Void)? = nil
    public var viewForZooming: ((UIScrollView) -> UIView?)? = nil
    public var willBeginZooming: ((_ scrollView: UIScrollView, _ view: UIView?) -> Void)? = nil
    public var endZooming: ((_ scrollView: UIScrollView, _ view: UIView?, _ scale: CGFloat) -> Void)? = nil
    public var didZoom: ((UIScrollView) -> Void)? = nil
    public var endScrollingAnimation: ((UIScrollView) -> Void)? = nil
    public var didChangeAdjustedContentInset: ((UIScrollView) -> Void)? = nil
}
