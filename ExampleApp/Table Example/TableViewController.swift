//
//  FirstViewController.swift
//  ExampleApp
//
//  Created by Daniele Margutti on 21/04/2018.
//  Copyright © 2018 FlowKit. All rights reserved.
//

import UIKit

class OffsetController {
    let scrollView: UIScrollView

    var oldContentHeight: CGFloat = 0.0
    var oldContentOffsetY: CGFloat = 0.0

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }

    func saveOffset() {
        self.oldContentHeight = self.scrollView.contentSize.height
        self.oldContentOffsetY = self.scrollView.contentOffset.y
    }

    func restoreOffset() {

        // It's necessary to launch layout updates before resetting the content offset.
        // Otherwise system will keep the current offset and content will jump to the top cell.
        self.scrollView.setNeedsLayout()
        self.scrollView.layoutIfNeeded()

        // When we calculate new offset we need take into account the adjusted content inset.
        let contentOffsetYAdjustment = max(-scrollView.adjustedContentInset.top, self.oldContentOffsetY)

        let newContentHeight = self.scrollView.contentSize.height
        let newContentOffsetY = newContentHeight - self.oldContentHeight + contentOffsetYAdjustment

        self.scrollView.contentOffset.y = newContentOffsetY
    }
}

class TableViewController: UIViewController {
    enum PaginateDirection {
        case backward
        case forward
    }

	@IBOutlet public var tableView: UITableView!
    
    lazy var director = TableDirector(tableView)

    lazy var articleCellSizesCalculator = ArticleCellSizesCalculator()
    lazy var offsetController = OffsetController(scrollView: tableView)

    var backwardIteration = 0
    var forwardIteration = 0

    var isReloading = false

    var isScrollingToTop = false

    // MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

        self.director.headerHeight = 24.0

		self.director.register(adapter: ArticleCellAdapter())

        self.director.onScroll?.shouldScrollToTop = { [weak self] scrollView in

            print("shouldScrollToTop")

            self?.isScrollingToTop = true

            return true
        }

        self.director.onScroll?.didScrollToTop = { [weak self] scrollView in

            print("didScrollToTop")

            self?.paginate(direction: .backward)

            self?.isScrollingToTop = false
        }

        self.director.onScroll?.endScrollingAnimation = { scrollView in
            print("endScrollingAnimation")
        }

        self.director.onScroll?.endDecelerating = { scrollView in
            print("endDecelerating")
        }

        self.director.onScroll?.didScroll = { [weak self] scrollView in

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
            self.offsetController.saveOffset()

            self.prependAndReload()

            self.offsetController.restoreOffset()

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
        self.director.add(section: section, at: 0)
        self.director.reloadData()
    }

    func appendAndReload() {
        let models: [ArticleCellModel] = (0..<20).map { index in
            let title = "Title: \(self.forwardIteration).\(index)\n\(loremIpsum)"
            let contentHeight = self.articleCellSizesCalculator.calculateContentHeight(with: title, fixedWidth: self.tableView.frame.width)
            return ArticleCellModel(title: title, contentHeight: contentHeight)
        }
        let section = TableSection(headerTitle: "Header \(self.forwardIteration)", footerTitle: nil, models: models)
        self.director.add(section: section, at: nil)
        self.director.reloadData()
    }
}
