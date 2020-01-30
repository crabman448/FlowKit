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

    var isScrollingToTop = false

    // MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

        self.tableView.director.headerHeight = 24.0

		self.tableView.director.register(adapter: ArticleCellAdapter())

        self.tableView.director.onScroll?.shouldScrollToTop = { [weak self] scrollView in

            print("shouldScrollToTop")

            self?.isScrollingToTop = true

            return true
        }

        self.tableView.director.onScroll?.didScrollToTop = { [weak self] scrollView in

            print("didScrollToTop")

            self?.paginate(direction: .backward)

            self?.isScrollingToTop = false
        }

        self.tableView.director.onScroll?.endScrollingAnimation = { [weak self] scrollView in
            print("endScrollingAnimation")
        }

        self.tableView.director.onScroll?.endDecelerating = { [weak self] scrollView in
            print("endDecelerating")
        }

        self.tableView.director.onScroll?.didScroll = { [weak self] scrollView in

            print("didScroll")

            guard let this = self, !this.isScrollingToTop else { return }

            let pagnationShiftValue: CGFloat = 200

            let scrollTopThreshold = pagnationShiftValue
            let scrollBottomThreshold = scrollView.contentSize.height - scrollView.bounds.height - pagnationShiftValue

            if scrollView.contentOffset.y < scrollTopThreshold {
                this.paginate(direction: .backward)
            } else if scrollView.contentOffset.y > scrollBottomThreshold {
                this.paginate(direction: .forward)
            }
        }
	}

    // MARK: Paginate

    func paginate(direction: PaginateDirection) {
        guard !isReloading else {
            return
        }

        isReloading = true

        switch direction {
        case .backward:
            backwardIteration -= 1

        case .forward:
            forwardIteration += 1
        }

        switch direction {
        case .backward:
            let oldContentHeight = self.tableView.contentSize.height
            let oldContentOffsetY = self.tableView.contentOffset.y

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

        // It's necessary to launch layout updates before resetting the content offset.
        // Otherwise system will keep the current offset and content will jump to the top cell.
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()

        // When we calculate new offset we need take into account the adjusted content inset.
        let contentOffsetYAdjustment = max(-tableView.adjustedContentInset.top, oldContentOffsetY)

        let newContentHeight = self.tableView.contentSize.height
        let newContentOffsetY = newContentHeight - oldContentHeight + contentOffsetYAdjustment

        self.tableView.contentOffset.y = newContentOffsetY
    }
}
