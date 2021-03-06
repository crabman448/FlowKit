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

open class CollectionDirector: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    
    public struct Events {
        typealias HeaderFooterEvent = (view: UICollectionReusableView, path: IndexPath, table: UICollectionView)
        
        var layoutDidChange: ((_ old: UICollectionViewLayout, _ new: UICollectionViewLayout) -> UICollectionViewTransitionLayout?)? = nil
        var targetOffset: ((_ proposedContentOffset: CGPoint) -> CGPoint)? = nil
        var moveItemPath: ((_ originalIndexPath: IndexPath, _ proposedIndexPath: IndexPath) -> IndexPath)? = nil
        
        var shouldUpdateFocus: ((_ context: UICollectionViewFocusUpdateContext) -> Bool)?
        var didUpdateFocus: ((_ context: UICollectionViewFocusUpdateContext, _ coordinator: UIFocusAnimationCoordinator) -> Void)?
        
        var willDisplayHeader : ((HeaderFooterEvent) -> Void)? = nil
        var willDisplayFooter : ((HeaderFooterEvent) -> Void)? = nil
        
        var endDisplayHeader : ((HeaderFooterEvent) -> Void)? = nil
        var endDisplayFooter : ((HeaderFooterEvent) -> Void)? = nil
    }
    
    /// Managed collection view
    public let collection: UICollectionView
    
    /// Registered cell, header/footer identifiers for given collection view.
    public let reusableRegister: ReusableRegister
    
    /// Registered adapters for this collection manager
    public private(set) var adaptersByModel: [String: AbstractAdapterProtocol] = [:]
    public private(set) var adaptersByCell: [String: AbstractAdapterProtocol] = [:]
    
    /// Set it to `true` to enable cell prefetching. By default is set to `false`.
    public var prefetchEnabled: Bool {
        set {
            switch newValue {
            case true: self.collection.prefetchDataSource = self
            case false: self.collection.prefetchDataSource = nil
            }
        }
        get {
            return (self.collection.prefetchDataSource != nil)
        }
    }
    
    /// Sections of the collection
    public private(set) var sections: [CollectionSection] = []
    
    /// Events of the collection
    public var on = CollectionDirector.Events()
    
    /// Events for UIScrollViewDelegate
    public var onScroll: ScrollViewEvents? = ScrollViewEvents()
    
    /// Initialize a new collection manager with given collection instance.
    ///
    /// - Parameter collection: instance of the collection to manage.
    public init(_ collection: UICollectionView) {
        self.collection = collection
        self.reusableRegister = ReusableRegister(collection)
        
        super.init()
        
        self.collection.dataSource = self
        self.collection.delegate = self
    }
    
    //MARK: Public Methods
    
    /// Return item at path.
    ///
    /// - Parameters:
    ///   - indexPath: index path to retrive
    ///   - safe: `true` to return nil if path is invalid, `false` to perform an unchecked retrive.
    /// - Returns: model
    public func item(at indexPath: IndexPath, safe: Bool = true) -> ModelProtocol? {
        guard safe else {
            return self.sections[indexPath.section].models[indexPath.item]
        }
        
        guard indexPath.section < self.sections.count else {
            return nil
        }
        let section = self.sections[indexPath.section]
        
        guard indexPath.item < section.models.count else {
            return nil
        }
        return section.models[indexPath.item]
    }
    
    /// Reload collection.
    ///
    /// - Parameter after: 	if defined a block animation is performed considering changes applied to the model;
    ///						if `nil` reload is performed without animation.
    public func reloadData(
        after task: ((CollectionDirector) -> (Void))? = nil,
        onEnd: (() -> (Void))? = nil
    ) {
        guard let task = task else {
            
            // Calling reloadData to indicate new items availability
            self.collection.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                onEnd?()
            })
            
            return
        }
        
        // Keep a reference to removed items in order to perform diff and animation
        let oldSections: [CollectionSection] = self.sections
        let oldItemsInSections: [String: [ModelProtocol]] = oldSections.reduce(into: [:], { $0[$1.modelId] = $1.models })
        
        // Execute task
        task(self)
        
        self.collection.performBatchUpdates({
            // Apply changes for sections
            let sectionChanges = SectionChanges.fromCollectionSections(old: oldSections, new: self.sections)
            sectionChanges.applyChanges(to: self.collection)
            
            // Apply changes for items inside sections
            for (newSectionIndex, newSection) in self.sections.enumerated() {
                if let oldItemsInSection = oldItemsInSections[newSection.modelId] {
                    let newItemsInSection = newSection.models
                    
                    let itemsDiff = diff(old: oldItemsInSection, new: newItemsInSection)
                    let itemsChanges = SectionItemsChanges.create(fromChanges: itemsDiff, section: newSectionIndex)
                    itemsChanges.applyChanges(of: self.collection)
                } else {
                    let indexPaths = (0..<newSection.models.count).map { IndexPath(item: $0, section: newSectionIndex) }
                    self.collection.insertItems(at: indexPaths)
                }
            }
            
        }, completion: { _ in
            onEnd?()
        })
    }
    
    
    /// Register an adapter.
    /// Adapter manage a single model type and associate it to a visual representation (a cell).
    ///
    /// - Parameter adapter: adapter to register
    public func register(adapter: AbstractAdapterProtocol) {
        let modelId = String(describing: adapter.modelType)
        let cellId = String(describing: adapter.cellType)
        self.adaptersByModel[modelId] = adapter
        self.adaptersByCell[cellId] = adapter
        self.reusableRegister.registerCell(forAdapter: adapter)
    }
    
    /// Register multiple adapters for collection.
    ///
    /// - Parameter adapters: adapters
    public func register(adapters: [AbstractAdapterProtocol]) {
        adapters.forEach { self.register(adapter: $0) }
    }
    
    //MARK: Manage Content
    
    /// Change the content of the table.
    ///
    /// - Parameter models: array of models to set.
    public func set(sections: [CollectionSection]) {
        self.sections = sections
    }
    
    /// Create a new section, append it at the end of the sections list and insert in it passed models.
    ///
    /// - Parameter models: models of the section
    /// - Returns: added section instance
    @discardableResult
    public func add(models: [ModelProtocol]) -> CollectionSection {
        let section = CollectionSection(models: models)
        self.sections.append(section)
        return section
    }
    
    /// Add a new section at given index.
    ///
    /// - Parameters:
    ///   - section: section to insert.
    ///   - index: destination index; if `nil` it will be append at the end of the list.
    public func add(_ section: CollectionSection, at index: Int? = nil) {
        guard let i = index, i < self.sections.count else {
            self.sections.append(section)
            return
        }
        self.sections.insert(section, at: i)
    }
    
    /// Add a list of the section starting at given index.
    ///
    /// - Parameters:
    ///   - sections: sections to append
    ///   - index: destination index; if `nil` it will be append at the end of the list.
    public func add(sections: [CollectionSection], at index: Int? = nil) {
        guard let i = index, i < self.sections.count else {
            self.sections.append(contentsOf: sections)
            return
        }
        self.sections.insert(contentsOf: sections, at: i)
    }
    
    /// Remove all sections from the collection.
    ///
    /// - Returns: number of removed sections.
    @discardableResult
    public func removeAll(keepingCapacity kp: Bool = false) -> Int {
        let count = self.sections.count
        self.sections.removeAll(keepingCapacity: kp)
        return count
    }
    
    /// Remove section at index from the collection.
    /// If index is not valid it does nothing.
    ///
    /// - Parameter index: index of the section to remove.
    /// - Returns: removed section
    @discardableResult
    public func remove(section index: Int) -> CollectionSection? {
        guard index < self.sections.count else {
            return nil
        }
        return self.sections.remove(at: index)
    }
    
    /// Remove sections at given indexes.
    /// Invalid indexes are ignored.
    ///
    /// - Parameter indexes: indexes to remove.
    /// - Returns: removed sections.
    @discardableResult
    public func remove(sectionsAt indexes: IndexSet) -> [CollectionSection] {
        var removed: [CollectionSection] = []
        indexes.reversed().forEach {
            if $0 < self.sections.count {
                removed.append(self.sections.remove(at: $0))
            }
        }
        return removed
    }
    
    /// Get section at given index.
    ///
    /// - Parameter index: index, if invalid produces `nil` result.
    /// - Returns: section instance if index is valid, `nil` otherwise.
    public func section(at index: Int) -> CollectionSection? {
        guard index < self.sections.count else {
            return nil
        }
        return self.sections[index]
    }
    
    /// Get the first section if exists.
    ///
    /// - Returns: first section, `nil` if has no sections.
    public func firstSection() -> CollectionSection? {
        return self.sections.first
    }
    
    /// Get the last section if exists.
    ///
    /// - Returns: last section, `nil` if has no sections.
    public func lastSection() -> CollectionSection? {
        return self.sections.last
    }
    
    //MARK: Internal Functions
    
    internal func adapter(for cell: UICollectionViewCell) -> ICollectionAdapterInternal {
        return adaptersByCell[String(describing: type(of: cell.self))] as! ICollectionAdapterInternal
    }
    
    /// Return the context for an element at given index.
    /// It returns the instance of the model and the registered adapter used to represent it.
    ///
    /// - Parameter index: index path of the item.
    /// - Returns: context
    internal func context(forItemAt index: IndexPath) -> (ModelProtocol, ICollectionAdapterInternal) {
        let model: ModelProtocol = self.sections[index.section].models[index.item]
        let modelId = String(describing: type(of: model.self))
        guard let adapter = self.adaptersByModel[modelId] else {
            fatalError("Failed to found an adapter for \(modelId)")
        }
        return (model, adapter as! ICollectionAdapterInternal)
    }
    
    internal func context(forModel model: ModelProtocol) -> ICollectionAdapterInternal {
        let modelId = String(describing: type(of: item.self))
        guard let adapter = self.adaptersByModel[modelId] else {
            fatalError("Failed to found an adapter for \(modelId)")
        }
        return (adapter as! ICollectionAdapterInternal)
    }
    
    internal func adapters(forIndexPath paths: [IndexPath]) -> [PrefetchModelsGroup] {
        var list: [String: PrefetchModelsGroup] = [:]
        paths.forEach { indexPath in
            let model = self.sections[indexPath.section].models[indexPath.item]
            let modelId = String(describing: type(of: model.self))
            
            let group: PrefetchModelsGroup
            if let existingGroup = list[modelId] {
                group = existingGroup
            } else {
                group = PrefetchModelsGroup(adapter: self.adaptersByModel[modelId] as! ICollectionAdapterInternal)
            }
            
            list[modelId] = group

            group.models.append(model)
            group.indexPaths.append(indexPath)
        }
        
        return Array(list.values)
    }
    
    //MARK: DataSource: Getting Item and Section Metrics
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections[section].models.count
    }
    
    //MARK: DataSource: Getting Views for Items
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let (model, adapter) = self.context(forItemAt: indexPath)
        let cell = adapter._instanceCell(in: collectionView, at: indexPath)
        adapter.dispatch(.dequeue, context: InternalContext(model, indexPath, cell, collectionView))
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = sections[indexPath.section]
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = section.headerView else {
                fatalError("Header is nil for section with ModelId \(section.modelId) at IndexPath \(indexPath)")
            }
            
            let identifier = self.reusableRegister.registerHeaderFooter(header, type: kind, at: indexPath)
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
            
            let headerItem = header as? ICollectionSectionViewInternal
            headerItem?.dispatch(.dequeue, type: .header, view: view, section: indexPath.section, collection: collectionView)
            
            return view
        case UICollectionView.elementKindSectionFooter:
            guard let footer = section.footerView else {
                fatalError("Footer is nil for section with ModelId \(section.modelId) at IndexPath \(indexPath)")
            }
            
            let identifier = self.reusableRegister.registerHeaderFooter(footer, type: kind, at: indexPath)
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
            
            let footerItem = footer as? ICollectionSectionViewInternal
            footerItem?.dispatch(.dequeue, type: .footer, view: view, section: indexPath.section, collection: collectionView)
            
            return view
        default:
            fatalError("Unknown kind \(kind) for section with ModelId \(section.modelId) at IndexPath \(indexPath)")
        }
    }
    
    //MARK: DataSource: Reordering Items
    
    //    TODO
    //
    //    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {}
    //    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {}
    
    //MARK: DataSource: Configuring an Index
    
    //    TODO
    //
    //    public func indexTitles(for collectionView: UICollectionView) -> [String]? {}
    //    public func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {}
    
    //MARK: Delegate: Managing the Selected Cells
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let (model, adapter) = self.context(forItemAt: indexPath)
        return ((adapter.dispatch(.shouldSelect, context: InternalContext(model, indexPath, nil, collectionView)) as? Bool) ?? true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let (model, adapter) = self.context(forItemAt: indexPath)
        adapter.dispatch(.didSelect, context: InternalContext(model, indexPath, nil, collectionView))
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let (model, adapter) = self.context(forItemAt: indexPath)
        return ((adapter.dispatch(.shouldDeselect, context: InternalContext(model, indexPath, nil, collectionView)) as? Bool) ?? true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let (model, adapter) = self.context(forItemAt: indexPath)
        adapter.dispatch(.didDeselect, context: InternalContext(model, indexPath, nil, collectionView))
    }
    
    //    TODO
    //
    //    public func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {}
    //    public func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {}
    //    public func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {}
    
    //MARK: Delegate: Managing Cell Highlighting
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let (model, adapter) = self.context(forItemAt: indexPath)
        return ((adapter.dispatch(.shouldHighlight, context: InternalContext(model, indexPath, nil, collectionView)) as? Bool) ?? true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let (model, adapter) = self.context(forItemAt: indexPath)
        adapter.dispatch(.didHighlight, context: InternalContext(model, indexPath, nil, collectionView))
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let (model, adapter) = self.context(forItemAt: indexPath)
        adapter.dispatch(.didUnhighlight, context: InternalContext(model, indexPath, nil, collectionView))
    }
    
    //MARK: Delegate: Tracking the Addition and Removal of Views
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let adapter = self.adapter(for: cell)
        adapter.dispatch(.willDisplay, context: InternalContext(nil, indexPath, cell, collectionView))
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            let header = reusableRegister.footer(at: indexPath) as? ICollectionSectionViewInternal
            header?.dispatch(.willDisplay, type: .header, view: view, section: indexPath.section, collection: collectionView)
            self.on.willDisplayHeader?( (view,indexPath,collectionView) )
        case UICollectionView.elementKindSectionFooter:
            let footer = reusableRegister.footer(at: indexPath) as? ICollectionSectionViewInternal
            footer?.dispatch(.willDisplay, type: .footer, view: view, section: indexPath.section, collection: collectionView)
            self.on.willDisplayFooter?( (view,indexPath,collectionView) )
        default:
            break
        }
        view.layer.zPosition = 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let adapter = self.adapter(for: cell)
        adapter.dispatch(.endDisplay, context: InternalContext(nil, indexPath, cell, collectionView))
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            let header = reusableRegister.header(at: indexPath) as? ICollectionSectionViewInternal
            header?.dispatch(.endDisplay, type: .header, view: view, section: indexPath.section, collection: collectionView)
        case UICollectionView.elementKindSectionFooter:
            let footer = reusableRegister.footer(at: indexPath) as? ICollectionSectionViewInternal
            footer?.dispatch(.endDisplay, type: .footer, view: view, section: indexPath.section, collection: collectionView)
        default:
            break
        }
        on.endDisplayFooter?((view, indexPath, collectionView))
    }
    
    //MARK: Delegate: Handling Layout Changes
    
    public func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        guard let layout = self.on.layoutDidChange?(fromLayout,toLayout) else {
            return UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
        }
        return layout
    }
    
    public func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let offset = self.on.targetOffset?(proposedContentOffset) else {
            return proposedContentOffset
        }
        return offset
    }
    
    public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        guard let path = self.on.moveItemPath?(originalIndexPath,proposedIndexPath) else {
            return proposedIndexPath
        }
        return path
    }
    
    //MARK: Delegate: Managing Context Menus
    
    public func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let (model, adapter) = self.context(forItemAt: indexPath)
        return adapter.dispatch(.contextMenuConfiguration, context: InternalContext(model, indexPath, nil, collectionView)) as? UIContextMenuConfiguration
    }
    
    //    TODO
    //
    //    public func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {}
    //    public func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {}
    //    public func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {}
    //    public func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {}
    //    public func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {}
    
    //MARK: Delegate: Managing Focus in a Collection View
    
    public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        let (model, adapter) = self.context(forItemAt: indexPath)
        return ((adapter.dispatch(.canFocus, context: InternalContext(model, indexPath, nil, collectionView)) as? Bool) ?? true)
    }
    
    //    TODO
    //
    //    public func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {}
    
    public func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        guard let update = self.on.shouldUpdateFocus?(context) else {
            return true
        }
        return update
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        self.on.didUpdateFocus?(context,coordinator)
    }
    
    //MARK: Delegate: Editing Items
    
    //    TODO
    //
    //    public func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {}
    
    //MARK: Delegate: Controlling the Spring-Loading Behavior
    
    public func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        let (model, adapter) = self.context(forItemAt: indexPath)
        return ((adapter.dispatch(.shouldSpringLoad, context: InternalContext(model, indexPath, nil, collectionView)) as? Bool) ?? true)
    }
    
    //MARK: Delegate: Managing Actions for Cells
    
    public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        let (model, adapter) = self.context(forItemAt: indexPath)
        return ((adapter.dispatch(.shouldShowEditMenu, context: InternalContext(model, indexPath, nil, collectionView)) as? Bool) ?? false)
    }
    
    public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let (model, adapter) = self.context(forItemAt: indexPath)
        return ((adapter.dispatch(.canPerformEditAction, context: InternalContext(model, indexPath, nil, collectionView, param1: action, param2: sender)) as? Bool) ?? true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        let (model, adapter) = self.context(forItemAt: indexPath)
        adapter.dispatch(.performEditAction, context: InternalContext(model, indexPath, nil, collectionView, param1: action, param2: sender))
    }
    
    //MARK: UICollectionViewDataSourcePrefetching
    
    internal class PrefetchModelsGroup {
        let adapter: 	ICollectionAdapterInternal
        var models: 	[ModelProtocol] = []
        var indexPaths: [IndexPath] = []
        
        public init(adapter: ICollectionAdapterInternal) {
            self.adapter = adapter
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        self.adapters(forIndexPath: indexPaths).forEach {
            $0.adapter.dispatch(.prefetch, context: InternalContext($0.models, $0.indexPaths, collectionView))
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        self.adapters(forIndexPath: indexPaths).forEach {
            $0.adapter.dispatch(.cancelPrefetch, context: InternalContext($0.models, $0.indexPaths, collectionView))
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.onScroll?.didScroll?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.onScroll?.willBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.onScroll?.willEndDragging?(scrollView,velocity,targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.onScroll?.endDragging?(scrollView,decelerate)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return (self.onScroll?.shouldScrollToTop?(scrollView) ?? true)
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.onScroll?.didScrollToTop?(scrollView)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.onScroll?.willBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.onScroll?.endDecelerating?(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.onScroll?.viewForZooming?(scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.onScroll?.willBeginZooming?(scrollView,view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.onScroll?.endZooming?(scrollView,view,scale)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.onScroll?.didZoom?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.onScroll?.endScrollingAnimation?(scrollView)
    }
    
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        self.onScroll?.didChangeAdjustedContentInset?(scrollView)
    }
    
    // MARK: ReusableRegister
    
    /// It keeps the status of the registration of both cell and header/footer reusable identifiers
    public class ReusableRegister {
        
        /// Managed collection
        public private(set) weak var collection: UICollectionView?
        
        /// Registered cell identifiers
        public private(set) var reuseIdentifiers: Set<String> = []
        
        /// Registered headers by IndexPath
        public private(set) var headers: [IndexPath: ICollectionSectionView] = [:]
        
        /// Registered footers by IndexPath
        public private(set) var footers: [IndexPath: ICollectionSectionView] = [:]
        
        /// Initialize a new register manager for given collection.
        ///
        /// - Parameter collection: collection instance
        internal init(_ collection: UICollectionView) {
            self.collection = collection
        }
        
        /// Register cell defined inside given adapter.
        /// If cell is already registered this operation does nothing.
        ///
        /// - Parameter adapter: adapter to register
        @discardableResult
        internal func registerCell(forAdapter adapter: AbstractAdapterProtocol) -> Bool {
            let reuseIdentifier = adapter.cellReuseIdentifier

            guard !reuseIdentifiers.contains(reuseIdentifier) else {
                return false
            }

            let bundle = Bundle(for: adapter.cellClass)

            if bundle.path(forResource: reuseIdentifier, ofType: "nib") != nil {
                collection?.register(UINib(nibName: reuseIdentifier, bundle: bundle), forCellWithReuseIdentifier: reuseIdentifier)
            } else if adapter.registerAsClass {
                collection?.register(adapter.cellClass, forCellWithReuseIdentifier: reuseIdentifier)
            }

            reuseIdentifiers.insert(reuseIdentifier)

            return true
        }
        
        /// Register header/footer identifier as needed.
        /// If already registered this operation does nothing.
        ///
        /// - Parameters:
        ///   - headerFooter: header/footer item to register
        ///   - type: is it header or footer
        /// - Returns: registered identifier
        @discardableResult
        internal func registerHeaderFooter(_ headerFooter: ICollectionSectionView, type: String, at indexPath: IndexPath) -> String {
            let reuseIdentifier = headerFooter.reuseIdentifier
            
            let headerShouldRegister = type == UICollectionView.elementKindSectionHeader && !headers.contains(where: { $0.key == indexPath })
            let footerShouldRegister = type == UICollectionView.elementKindSectionFooter && !footers.contains(where: { $0.key == indexPath })
            
            guard headerShouldRegister || footerShouldRegister else {
                return reuseIdentifier
            }
            
            if type == UICollectionView.elementKindSectionHeader {
                headers[indexPath] = headerFooter
            }
            
            if type == UICollectionView.elementKindSectionFooter {
                footers[indexPath] = headerFooter
            }
            
            if headerFooter.registerAsClass {
                collection?.register(
                    headerFooter.viewClass,
                    forSupplementaryViewOfKind: type,
                    withReuseIdentifier: reuseIdentifier
                )
            } else {
                collection?.register(
                    UINib(nibName: reuseIdentifier, bundle: Bundle(for: headerFooter.viewClass)),
                    forSupplementaryViewOfKind: type,
                    withReuseIdentifier: reuseIdentifier
                )
            }
            
            return reuseIdentifier
        }
        
        func header(at indexPath: IndexPath) -> ICollectionSectionView? {
            return headers[indexPath]
        }
        
        func footer(at indexPath: IndexPath) -> ICollectionSectionView? {
            return footers[indexPath]
        }
    }
}
