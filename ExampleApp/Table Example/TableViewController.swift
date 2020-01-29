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

    let tableSection = TableSection(models: nil)

    var backwardIteration = 0
    var forwardIteration = 0

    var isReloading = false

    var targetContentOffsetY: CGFloat?

    // MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.director.register(adapter: ArticleAdapter())

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

        self.tableView.director.set(sections: [tableSection])
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
            let oldContentHeight = tableView.contentSize.height
            let oldContentOffsetY = tableView.contentOffset.y

            print("oldContentHeight: \(oldContentHeight)")
            print("oldContentOffsetY: \(oldContentOffsetY)")

            prependAndReload()

            restoreOffset(oldContentHeight: oldContentHeight, oldContentOffsetY: oldContentOffsetY)

        case .forward:
            appendAndReload()
        }

        self.isReloading = false
    }

    // MARK: Append/Prepend

    func prependAndReload() {
        let models: [Article] = (0..<20).map { Article(title: "Title: \(self.backwardIteration).\($0)") }
        self.tableSection.add(models: models, at: 0)
        self.tableView.director.reloadData()
    }

    func appendAndReload() {
        let models: [Article] = (0..<20).map { Article(title: "Title: \(self.forwardIteration).\($0)") }
        self.tableSection.add(models: models, at: nil)
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
	
	func getWinnerSection() -> TableSection {
        let articles = (0..<7).map {
            return Article(title: "Article_Title_\($0)".loc)
        }

		let header = TableSectionView<TableExampleHeaderView>()
		header.on.willDisplay = { ctx in
            guard (ctx.table?.director.sections[ctx.section]) != nil else { return }

			ctx.view?.titleLabel?.text = "Header title"
		}
		header.on.height = { _ in
			return 150
		}

		let footer = TableSectionView<TableFooterExample>()
		footer.on.height = { _ in
			return 30
		}
		footer.on.dequeue = { ctx in
			ctx.view?.titleLabel?.text = "\(articles.count) Articles"
		}
		
		
		let section = TableSection(headerView: header, footerView: footer, models: articles)
		return section
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

public class ArticleAdapter: TableAdapter<Article,TableArticleCell> {
	
	init() {
		super.init()
		self.on.dequeue = { ctx in
			ctx.cell?.titleLabel?.text = ctx.model.title
		}
		self.on.tap = { ctx in
			ctx.cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
			print("Tapped on article \(ctx.model.modelId)")
			return .deselectAnimated
		}
        self.on.rowHeight = { _ in
            return 100
        }
        self.on.rowHeightEstimated = { _ in
            return 100
        }
	}
	
}

public class Article: ModelProtocol {

	public static func == (lhs: Article, rhs: Article) -> Bool {
		return (lhs.modelId == rhs.modelId)
	}
	
	public let title: String

	public init(title: String) {
		self.title = title
	}

	public var modelId: String {
		return title
	}
}

public class TableArticleCell: UITableViewCell {
	@IBOutlet public var titleLabel: UILabel?
}
