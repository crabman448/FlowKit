//
//	Flow
//	A declarative approach to UICollectionView & UITableView management
//	--------------------------------------------------------------------
//	Created by:	Daniele Margutti
//				hello@danielemargutti.com
//				http://www.danielemargutti.com
//
//	Twitter:	@danielemargutti
//
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

import Foundation
import UIKit

open class FlowCollectionDirector: CollectionDirector, UICollectionViewDelegateFlowLayout {
	
    public let layout: UICollectionViewFlowLayout
    
    /// Define the cell size.
    ///
    /// - `default`: standard behaviour (no auto sizing, needs to implement `onGetItemSize` on adapters).
    /// - estimated: uses autolayout to calculate the size of the cell. You can provide an
    ///                 estimated size of the cell to speed up the calculation.
    ///                 Implement preferredLayoutAttributesFitting(_:) method in your cell to evaluate the size.
    /// - fixed: fixed size where each item has the same size
    public enum ItemSize {
        case `default`
        case autoLayout(estimated: CGSize)
        case fixed(size: CGSize)
    }
    
    /// Internal representation of the cell size
    private var _itemSize: ItemSize = .default

    /// Define the size of the items into the cell (valid with `UICollectionViewFlowLayout` layout).
    public var itemSize: ItemSize {
        set {
            guard let layout = self.collection.collectionViewLayout as? UICollectionViewFlowLayout else {
                return
            }
            self._itemSize = newValue
            switch _itemSize {
            case .autoLayout(let estimateSize):
                layout.estimatedItemSize = estimateSize
                layout.itemSize = CGSize(width: 50.0, height: 50.0) // default
            case .fixed(let fixedSize):
                layout.estimatedItemSize = .zero
                layout.itemSize = fixedSize
            case .default:
                layout.estimatedItemSize = .zero
                layout.itemSize = CGSize(width: 50.0, height: 50.0) // default
            }
        }
        get {
            return _itemSize
        }
    }
    
	/// Margins to apply to content.
	/// This is a global value, you can customize a per-section behaviour by implementing `sectionInsets` property into a section.
	/// Initially is set to `.zero`.
	public var sectionsInsets: UIEdgeInsets {
		set { self.layout.sectionInset = newValue }
		get { return self.layout.sectionInset }
	}
	
	/// Minimum spacing (in points) to use between items in the same row or column.
	/// This is a global value, you can customize a per-section behaviour by implementing `minimumInteritemSpacing` property into a section.
	/// Initially is set to `CGFloat.leastNormalMagnitude`.
	public var minimumInteritemSpacing: CGFloat {
		set { self.layout.minimumInteritemSpacing = newValue }
		get { return self.layout.minimumInteritemSpacing }
	}
	
	/// The minimum spacing (in points) to use between rows or columns.
	/// This is a global value, you can customize a per-section behaviour by implementing `minimumInteritemSpacing` property into a section.
	/// Initially is set to `0`.
	public var minimumLineSpacing: CGFloat {
		set { self.layout.minimumLineSpacing = newValue }
		get { return self.layout.minimumLineSpacing }
	}
	
	/// When this property is true, section header views scroll with content until they reach the top of the screen,
	/// at which point they are pinned to the upper bounds of the collection view.
	/// Each new header view that scrolls to the top of the screen pushes the previously pinned header view offscreen.
	///
	/// The default value of this property is `false`.
	public var stickyHeaders: Bool {
		set { self.layout.sectionHeadersPinToVisibleBounds = newValue }
		get { return (self.layout.sectionHeadersPinToVisibleBounds) }
	}
	
	/// When this property is true, section footer views scroll with content until they reach the bottom of the screen,
	/// at which point they are pinned to the lower bounds of the collection view.
	/// Each new footer view that scrolls to the bottom of the screen pushes the previously pinned footer view offscreen.
	///
	/// The default value of this property is `false`.
	public var stickyFooters: Bool {
		set { self.layout.sectionFootersPinToVisibleBounds = newValue }
		get { return (self.layout.sectionFootersPinToVisibleBounds) }
	}

	/// Set the section reference starting point.
    public var sectionInsetReference: UICollectionViewFlowLayout.SectionInsetReference {
		set { self.layout.sectionInsetReference = newValue }
		get { return self.layout.sectionInsetReference }
	}
	
	/// Initialize a new flow collection manager.
	/// Note: Layout of the collection must be a UICollectionViewFlowLayout or subclass.
	///
	/// - Parameters:
	///   - collection: collection instance to manage.
    public override init(_ collection: UICollectionView) {
        guard let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("Expected UICollectionViewFlowLayout")
        }
        
        self.layout = layout
        
		super.init(collection)
	}
	
	//MARK: UICollectionViewDelegateFlowLayout Events
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let (model,adapter) = self.context(forItemAt: indexPath)

        let potentialItemSizeValue = adapter.dispatch(.itemSize, context: InternalContext(model, indexPath, nil, collectionView)) as? CGSize

		switch self.itemSize {
		case .default, .autoLayout(_):
            return potentialItemSizeValue ?? self.layout.itemSize
		case .fixed(let itemSizeValue):
			return potentialItemSizeValue ?? itemSizeValue
		}
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		guard let value = self.sections[section].sectionInsets?() else {
			return self.sectionsInsets
		}
		return value
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		guard let value = self.sections[section].minimumInterItemSpacing?() else {
			return self.minimumInteritemSpacing
		}
		return value
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		guard let value = self.sections[section].minimumLineSpacing?() else {
			return self.minimumLineSpacing
		}
		return value
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		let header = (sections[section].header as? AbstractCollectionHeaderFooterItem)
		guard let size = header?.dispatch(.referenceSize, type: .header, view: nil, section: section, collection: collectionView) as? CGSize else {
			return .zero
		}
		return size
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
		let footer = (sections[section].footer as? AbstractCollectionHeaderFooterItem)
		guard let size = footer?.dispatch(.referenceSize, type: .footer, view: nil, section: section, collection: collectionView) as? CGSize else {
			return .zero
		}
		return size
	}
	
}
