//
//  FirstViewController.swift
//  ExampleApp
//
//  Created by Daniele Margutti on 21/04/2018.
//  Copyright © 2018 FlowKit. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    enum PaginateDirection {
        case backward
        case forward
    }

	@IBOutlet public var tableView: UITableView!

    let articleCellSizesCalculator = ArticleCellSizesCalculator()

    var backwardIteration = 0
    var forwardIteration = 0

    var isReloading = false

    var targetContentOffsetY: CGFloat?

    // MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

        self.tableView.director.headerHeight = 24.0

		self.tableView.director.register(adapter: ArticleCellAdapter())

        self.tableView.director.onScroll?.didScroll = { [weak self] scrollView in
            guard let this = self else { return }

            let pagnationShiftValue: CGFloat = 200

            let scrollTopThreshold = pagnationShiftValue
            let scrollBottomThreshold = scrollView.contentSize.height - scrollView.bounds.height - pagnationShiftValue

            if scrollView.contentOffset.y < scrollTopThreshold {
                this.paginate(direction: .backward)
            } else if scrollView.contentOffset.y > scrollBottomThreshold {
                this.paginate(direction: .forward)
            }
        }

        self.tableView.director.onScroll?.willBeginDragging = { [weak self] scrollView in
            self?.targetContentOffsetY = nil
        }

        self.tableView.director.onScroll?.willEndDragging = { [weak self] scrollView, velocity, targetContentOffset in
            self?.targetContentOffsetY = targetContentOffset.pointee.y
        }
	}

    // MARK: Paginate

    func paginate(direction: PaginateDirection) {
        guard !isReloading else {
            return
        }

        switch direction {
        case .backward:
            backwardIteration -= 1

        case .forward:
            forwardIteration += 1
        }

        isReloading = true
        
        switch direction {
        case .backward:
            let oldContentHeight = self.tableView.contentSize.height
            let oldContentOffsetY = self.tableView.contentOffset.y

            print("oldContentHeight: \(oldContentHeight)")
            print("oldContentOffsetY: \(oldContentOffsetY)")

            self.prependAndReload()

            self.restoreOffset(oldContentHeight: oldContentHeight, oldContentOffsetY: oldContentOffsetY)

        case .forward:
            self.appendAndReload()
        }

        self.isReloading = false
    }

    // MARK: Append/Prepend

    let loremIpsum = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."

    func prependAndReload() {
        let models: [ArticleCellModel] = (0..<20).map { index in
            let title = "Title: \(self.backwardIteration).\(index)\n\(loremIpsum)"
            let contentHeight = self.articleCellSizesCalculator.calculateContentHeight(with: title, fixedWidth: self.tableView.frame.width)
            return ArticleCellModel(title: title, contentHeight: contentHeight)
        }
        let section = TableSection(headerTitle: "Header \(self.backwardIteration)", footerTitle: nil, models: models)
        self.tableView.director.add(section: section, at: 0)
        self.tableView.director.reloadData()
    }

    func appendAndReload() {
        let models: [ArticleCellModel] = (0..<20).map { index in
            let title = "Title: \(self.forwardIteration).\(index)\n\(loremIpsum)"
            let contentHeight = self.articleCellSizesCalculator.calculateContentHeight(with: title, fixedWidth: self.tableView.frame.width)
            return ArticleCellModel(title: title, contentHeight: contentHeight)
        }
        let section = TableSection(headerTitle: "Header \(self.forwardIteration)", footerTitle: nil, models: models)
        self.tableView.director.add(section: section, at: nil)
        self.tableView.director.reloadData()
    }

    // MARK: RestoreOffset

    func restoreOffset(oldContentHeight: CGFloat, oldContentOffsetY: CGFloat) {

        self.tableView.layoutIfNeeded()

        let contentOffsetYAdjustment: CGFloat
        if let targetContentOffsetY = self.targetContentOffsetY {
            contentOffsetYAdjustment = targetContentOffsetY
        } else {
            contentOffsetYAdjustment = oldContentOffsetY
        }

        let newContentHeight = self.tableView.contentSize.height
        let newContentOffsetY = newContentHeight - oldContentHeight + contentOffsetYAdjustment

        print("newContentHeight: \(newContentHeight)")
        print("newContentOffsetY: \(newContentOffsetY)")

        print()

        self.tableView.contentOffset.y = newContentOffsetY
    }
}
