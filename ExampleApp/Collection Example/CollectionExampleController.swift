//
//  CollectionExampleController.swift
//  ExampleApp
//
//  Created by Daniele Margutti on 21/04/2018.
//  Copyright © 2018 FlowKit. All rights reserved.
//

import UIKit

public struct Number: ModelProtocol {
	public var modelId: String {
		return String(value)
	}
	
	let value: Int
	
	init(_ value: Int) {
		self.value = value
	}
}

public struct Letter: ModelProtocol {
	public var modelId: String {
		return self.value
	}
	
	let value: String
	
	init(_ value: String) {
		self.value = value
	}
}

class CollectionExampleController: UIViewController {
	
	@IBOutlet var collectionView: UICollectionView!

	lazy var director = FlowCollectionDirector(collectionView)
	
	override func viewDidLoad() {
		super.viewDidLoad()

        setupDirector()
        reload(displayHeader: true)
	}

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.reload(displayHeader: true)
            }
        }
    }

    func setupDirector() {
        let letterAdapter = CollectionAdapter<Letter,LetterCell>()
        letterAdapter.on.dequeue = { ctx in
            ctx.cell?.label?.text = "\(ctx.model)"
        }
        letterAdapter.on.didSelect = { ctx in
            print("Tapped letter \(ctx.model)")
        }
        letterAdapter.on.itemSize = { ctx in
            return CGSize.init(width: ctx.collectionSize!.width / 3.0, height: 100)
        }
        director.register(adapter: letterAdapter)

        let numberAdapter = CollectionAdapter<Number,NumberCell>()
        numberAdapter.on.dequeue = { ctx in
            ctx.cell?.label?.text = "#\(ctx.model)"
            ctx.cell?.back?.layer.borderWidth = 2
            ctx.cell?.back?.layer.borderColor = UIColor.darkGray.cgColor
            ctx.cell?.back?.backgroundColor = UIColor.white
        }
        numberAdapter.on.didSelect = { ctx in
            print("Tapped number \(ctx.model)")
        }
        numberAdapter.on.itemSize = { ctx in
            return CGSize.init(width: ctx.collectionSize!.width / 3.0, height: 100)
        }
        director.register(adapter: numberAdapter)
    }

    func reload(displayHeader: Bool) {
        var list: [ModelProtocol] = (0..<70).map { return Number($0) }
        list.append(contentsOf: [Letter("A"),Letter("B"),Letter("C"),Letter("D"),Letter("E"),Letter("F")])
        list.shuffle()

        let section: CollectionSection

        if displayHeader {
            let header = CollectionSectionView<CollectionHeader>()
            header.on.dequeue = { context in
                context.view?.label?.backgroundColor = .purple
            }
            header.on.referenceSize = { context in
                let width = context.collectionSize?.width ?? 0.0
                return CGSize(width: width, height: 40)
            }
            header.on.endDisplay = { context in
                print(context)
            }
            section = CollectionSection(list, headerView: header)
        } else {
            section = CollectionSection(list)
        }

        director.removeAll()
        director.add(section)
        director.reloadData()
    }

    func reset() {
        director.removeAll()
        director.reloadData()
    }
}

public class NumberCell: UICollectionViewCell {
	@IBOutlet public var label: UILabel?
	@IBOutlet public var back: UIView?
}


public class LetterCell: UICollectionViewCell {
	@IBOutlet public var label: UILabel?
}

extension MutableCollection {
	/// Shuffles the contents of this collection.
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			// Change `Int` in the next line to `IndexDistance` in < Swift 4.1
			let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			let i = index(firstUnshuffled, offsetBy: d)
			swapAt(firstUnshuffled, i)
		}
	}
}
