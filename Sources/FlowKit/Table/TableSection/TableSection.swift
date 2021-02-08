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

/// Represent a single section of the table
public class TableSection: ModelProtocol {

    /// Unique identifier of the section
    public let modelId: String
	
	/// Items inside the section.
	public var models: [ModelProtocol] = [] {
        didSet {
            onModelsDidSet?()
        }
    }

    /// Implement this method when you want to observe changes in models array
    public var onModelsDidSet: (() -> Void)?
	
	/// Title of the header; if `headerView` is set this value is ignored.
	public var headerTitle: String?
	
	/// Title of the footer; if `footerView` is set this value is ignored.
	public var footerTitle: String?
	
	/// View of the header
	public var headerView: ITableSectionView? {
		willSet {
			self.headerView?.section = nil
		}
		didSet {
			self.headerView?.section = self
		}
	}
	
	/// View of the footer
	public var footerView: ITableSectionView? {
		willSet {
			self.footerView?.section = nil
		}
		didSet {
			self.footerView?.section = self
		}
	}

    /// Initializer to create a copy of a TableSection
    ///
    /// - Parameter section: TableSection
    public required init(_ section: TableSection) {
        self.modelId = section.modelId
        self.models = section.models
        self.onModelsDidSet = section.onModelsDidSet
        self.headerTitle = section.headerTitle
        self.footerTitle = section.footerTitle
        self.headerView = section.headerView
        self.footerView = section.footerView
    }

	/// Initialize a new section with given initial models.
	///
	/// - Parameter models: items to add (`nil` means empty array)
    public init(modelId: String = UUID().uuidString, models: [ModelProtocol]?) {
        self.modelId = modelId
		self.models = (models ?? [])
	}
	
	/// Initialize a new section with given header/footer's titles and initial items.
	///
	/// - Parameters:
	///   - headerTitle: header title as string
	///   - footerTitle: footer title as string
	///   - models: models to add (`nil` means empty array)
	public convenience init(modelId: String = UUID().uuidString, headerTitle: String?, footerTitle: String?, models: [ModelProtocol]? = nil) {
        self.init(modelId: modelId, models: models)

		self.headerTitle = headerTitle
		self.footerTitle = footerTitle
	}
	
	/// Initialize a new section with given view for header/footer and initial items.
	///
	/// - Parameters:
	///   - headerView: header view
	///   - footerView: footer view
	///   - models: models to add (`nil` means empty array)
	public convenience init(modelId: String = UUID().uuidString, headerView: ITableSectionView?, footerView: ITableSectionView?, models: [ModelProtocol]? = nil) {
        self.init(modelId: modelId, models: models)

		self.headerView = headerView
		self.footerView = footerView
	}
	
	/// Equatable support.
	public static func == (lhs: TableSection, rhs: TableSection) -> Bool {
		return (lhs.modelId == rhs.modelId)
	}
	
	/// Change the content of the section.
	///
	/// - Parameter models: array of models to set.
	public func set(models: [ModelProtocol]) {
		self.models = models
	}
	
	/// Replace a model instance at specified index.
	///
	/// - Parameters:
	///   - model: new instance to use.
	///   - index: index of the instance to replace.
	/// - Returns: old instance, `nil` if provided `index` is invalid.
	@discardableResult
	public func set(model: ModelProtocol, at index: Int) -> ModelProtocol? {
		guard index >= 0, index < self.models.count else {
            return nil
        }
		let oldModel = self.models[index]
		self.models[index] = model
		return oldModel
	}

    /// Prepend or update item in section.
    ///
    /// - Parameters:
    ///   - model: Model to prepend or update
    public func prependOrUpdate(model: ModelProtocol) {
        if let indexToUpdate = models.firstIndex(where: { $0.modelId == model.modelId } ) {
            models[indexToUpdate] = model
        } else {
            models.insert(model, at: 0)
        }
    }

    /// Append or update item in section.
    ///
    /// - Parameters:
    ///   - model: Model to append or update
    public func appendOrUpdate(model: ModelProtocol) {
        if let indexToUpdate = models.firstIndex(where: { $0.modelId == model.modelId } ) {
            models[indexToUpdate] = model
        } else {
            models.append(model)
        }
    }
	
	/// Add item at given index.
	///
	/// - Parameters:
	///   - model: model to append
	///   - index: destination index; if invalid or `nil` model is append at the end of the list.
	public func add(model: ModelProtocol, at index: Int?) {
		guard let index = index, index < self.models.count else {
			self.models.append(model)
			return
		}
		self.models.insert(model, at: index)
	}
	
	/// Add models starting at given index of the array.
	///
	/// - Parameters:
	///   - models: models to insert.
	///   - index: destination starting index; if invalid or `nil` models are append at the end of the list.
	public func add(models: [ModelProtocol], at index: Int?) {
		guard let index = index, index < self.models.count else {
			self.models.append(contentsOf: models)
			return
		}
		self.models.insert(contentsOf: models, at: index)
	}
	
	/// Remove model at given index.
	///
	/// - Parameter index: index to remove.
	/// - Returns: removed model, `nil` if index is invalid.
	@discardableResult
	public func remove(at index: Int) -> ModelProtocol? {
		guard index < self.models.count else {
            return nil
        }
		return self.models.remove(at: index)
	}
	
	/// Remove model at given indexes set.
	///
	/// - Parameter indexes: indexes to remove.
	/// - Returns: an array of removed indexes starting from the lower index to the last one. Invalid indexes are ignored.
	@discardableResult
	public func remove(atIndexes indexes: IndexSet) -> [ModelProtocol] {
		var removed: [ModelProtocol] = []
		indexes.reversed().forEach {
			if $0 < self.models.count {
				removed.append(self.models.remove(at: $0))
			}
		}
		return removed
	}
	
	/// Remove all models into the section.
	///
	/// - Parameter kp: `true` to keep the capacity and optimize operations.
	/// - Returns: count removed items.
	@discardableResult
	public func removeAll(keepingCapacity kp: Bool = false) -> Int {
		let count = self.models.count
		self.models.removeAll(keepingCapacity: kp)
		return count
	}
	
	/// Swap model at given index to another destination index.
	///
	/// - Parameters:
	///   - sourceIndex: source index
	///   - destIndex: destination index
	public func move(swappingAt sourceIndex: Int, with destIndex: Int) {
		guard sourceIndex < self.models.count, destIndex < self.models.count else {
            return
        }
		self.models.swapAt(sourceIndex, destIndex)
	}
	
	/// Remove model at given index and insert at destination index.
	///
	/// - Parameters:
	///   - sourceIndex: source index
	///   - destIndex: destination index
	public func move(from sourceIndex: Int, to destIndex: Int) {
		guard sourceIndex < self.models.count, destIndex < self.models.count else {
            return
        }
		let removed = self.models.remove(at: sourceIndex)
		self.models.insert(removed, at: destIndex)
	}

    // MARK: Copy

    public var copy: TableSection {
        return type(of: self).init(self)
    }
}
