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
	
    public var layout: UICollectionViewFlowLayout? {
        return collection.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
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

    /// Define the size of the items into the cell (valid with `UICollectionViewFlowLayout` layout).
    public var itemSize: ItemSize = .default {
        didSet {
            switch itemSize {
            case .autoLayout(let estimateSize):
                layout?.estimatedItemSize = estimateSize
                layout?.itemSize = CGSize(width: 50.0, height: 50.0) // default
            case .fixed(let fixedSize):
                layout?.estimatedItemSize = .zero
                layout?.itemSize = fixedSize
            case .default:
                layout?.estimatedItemSize = .zero
                layout?.itemSize = CGSize(width: 50.0, height: 50.0) // default
            }
        }
    }
	
	//MARK: UICollectionViewDelegateFlowLayout Events
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let (model,adapter) = self.context(forItemAt: indexPath)

        let potentialItemSizeValue = adapter.dispatch(.itemSize, context: InternalContext(model, indexPath, nil, collectionView)) as? CGSize

		switch self.itemSize {
		case .default, .autoLayout(_):
            return potentialItemSizeValue ?? self.layout?.itemSize ?? .zero
		case .fixed(let itemSizeValue):
			return potentialItemSizeValue ?? itemSizeValue
		}
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		guard let value = self.sections[section].sectionInsets?() else {
            return self.layout?.sectionInset ?? .zero
		}
		return value
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		guard let value = self.sections[section].minimumInterItemSpacing?() else {
            return self.layout?.minimumInteritemSpacing ?? .zero
		}
		return value
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		guard let value = self.sections[section].minimumLineSpacing?() else {
            return self.layout?.minimumLineSpacing ?? .zero
		}
		return value
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		let headerView = (sections[section].headerView as? ICollectionSectionViewInternal)
		guard let size = headerView?.dispatch(.referenceSize, type: .header, view: nil, section: section, collection: collectionView) as? CGSize else {
			return .zero
		}
		return size
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
		let footerView = (sections[section].footerView as? ICollectionSectionViewInternal)
		guard let size = footerView?.dispatch(.referenceSize, type: .footer, view: nil, section: section, collection: collectionView) as? CGSize else {
			return .zero
		}
		return size
	}
	
}
