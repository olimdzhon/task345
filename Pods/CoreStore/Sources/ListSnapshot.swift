//
//  ListSnapshot.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import CoreData

#if canImport(UIKit)
import UIKit

#elseif canImport(AppKit)
import AppKit

#endif


// MARK: - ListSnapshot

/**
 A `ListSnapshot` holds a stable list of `DynamicObject` identifiers. This is typically created by a `ListPublisher` and are designed to work well with `DiffableDataSource.TableViewAdapter`s and `DiffableDataSource.CollectionViewAdapter`s. For detailed examples, see the documentation on `DiffableDataSource.TableViewAdapter` and `DiffableDataSource.CollectionViewAdapter`.

 While the `ListSnapshot` stores only object identifiers, all accessors to its items return `ObjectPublisher`s, which are lazily created. For more details, see the documentation on `ListObject`.

 Since `ListSnapshot` is a value type, you can freely modify its items.
 */
public struct ListSnapshot<O: DynamicObject>: RandomAccessCollection, Hashable {

    // MARK: Public (Accessors)

    /**
     The `DynamicObject` type associated with this list
     */
    public typealias ObjectType = O

    /**
     The type for the section IDs
     */
    public typealias SectionID = String

    /**
     The type for the item IDs
     */
    public typealias ItemID = O.ObjectID

    /**
     Returns the object at the given index.

     - parameter index: the index of the object. Using an index above the valid range will raise an exception.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified index
     */
    public subscript(index: Index) -> ObjectPublisher<O> {

        let context = self.context!
        let itemID = self.diffableSnapshot.itemIdentifiers[index]
        return context.objectPublisher(objectID: itemID)
    }

    /**
     Returns the object at the given index, or `nil` if out of bounds.

     - parameter index: the index for the object. Using an index above the valid range will return `nil`.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified index, or `nil` if out of bounds
     */
    public subscript(safeIndex index: Index) -> ObjectPublisher<O>? {

        guard let context = self.context else {

            return nil
        }
        let itemIDs = self.diffableSnapshot.itemIdentifiers
        guard itemIDs.indices.contains(index) else {

            return nil
        }
        let itemID = itemIDs[index]
        return context.objectPublisher(objectID: itemID)
    }

    /**
     Returns the object at the given `sectionIndex` and `itemIndex`.

     - parameter sectionIndex: the section index for the object. Using a `sectionIndex` with an invalid range will raise an exception.
     - parameter itemIndex: the index for the object within the section. Using an `itemIndex` with an invalid range will raise an exception.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified section and item index
     */
    public subscript(sectionIndex: Int, itemIndex: Int) -> ObjectPublisher<O> {

        let context = self.context!
        let snapshot = self.diffableSnapshot
        let sectionID = snapshot.sectionIdentifiers[sectionIndex]
        let itemID = snapshot.itemIdentifiers(inSection: sectionID)[itemIndex]
        return context.objectPublisher(objectID: itemID)
    }

    /**
     Returns the object at the given section and item index, or `nil` if out of bounds.

     - parameter sectionIndex: the section index for the object. Using a `sectionIndex` with an invalid range will return `nil`.
     - parameter itemIndex: the index for the object within the section. Using an `itemIndex` with an invalid range will return `nil`.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified section and item index, or `nil` if out of bounds
     */
    public subscript(safeSectionIndex sectionIndex: Int, safeItemIndex itemIndex: Int) -> ObjectPublisher<O>? {

        guard let context = self.context else {

            return nil
        }
        let snapshot = self.diffableSnapshot
        let sectionIDs = snapshot.sectionIdentifiers
        guard sectionIDs.indices.contains(sectionIndex) else {

            return nil
        }
        let sectionID = sectionIDs[sectionIndex]
        let itemIDs = snapshot.itemIdentifiers(inSection: sectionID)
        guard itemIDs.indices.contains(itemIndex) else {

            return nil
        }
        let itemID = itemIDs[itemIndex]
        return context.objectPublisher(objectID: itemID)
    }

    /**
     Returns the object at the given `IndexPath`.

     - parameter indexPath: the `IndexPath` for the object. Using an `indexPath` with an invalid range will raise an exception.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified index path
     */
    public subscript(indexPath: IndexPath) -> ObjectPublisher<O> {

        return self[indexPath[0], indexPath[1]]
    }

    /**
     Returns the object at the given `IndexPath`, or `nil` if out of bounds.

     - parameter indexPath: the `IndexPath` for the object. Using an `indexPath` with an invalid range will return `nil`.
     - returns: the `ObjectPublisher<O>` interfacing the object at the specified index path, or `nil` if out of bounds
     */
    public subscript(safeIndexPath indexPath: IndexPath) -> ObjectPublisher<O>? {

        return self[
            safeSectionIndex: indexPath[0],
            safeItemIndex: indexPath[1]
        ]
    }

    /**
     Checks if the `ListSnapshot` has at least one section

     - returns: `true` if at least one section exists, `false` otherwise
     */
    public func hasSections() -> Bool {

        return self.diffableSnapshot.numberOfSections > 0
    }

    /**
     Checks if the `ListSnapshot` has at least one object in any section.

     - returns: `true` if at least one object in any section exists, `false` otherwise
     */
    public func hasItems() -> Bool {

        return self.diffableSnapshot.numberOfItems > 0
    }

    /**
     Checks if the `ListSnapshot` has at least one object in the specified section.

     - parameter sectionIndex: the section index. Using an index outside the valid range will return `false`.
     - returns: `true` if at least one object in the specified section exists, `false` otherwise
     */
    public func hasItems(inSectionIndex sectionIndex: Int) -> Bool {

        let snapshot = self.diffableSnapshot
        let sectionIDs = snapshot.sectionIdentifiers
        guard sectionIDs.indices.contains(sectionIndex) else {

            return false
        }
        let sectionID = sectionIDs[sectionIndex]
        return snapshot.numberOfItems(inSection: sectionID) > 0
    }

    /**
     Checks if the `ListSnapshot` has at least one object the specified section.

     - parameter sectionID: the section identifier. Using an index outside the valid range will return `false`.
     - returns: `true` if at least one object in the specified section exists, `false` otherwise
     */
    public func hasItems(inSectionWithID sectionID: SectionID) -> Bool {

        let snapshot = self.diffableSnapshot
        guard snapshot.sectionIdentifiers.contains(sectionID) else {

            return false
        }
        return snapshot.numberOfItems(inSection: sectionID) > 0
    }

    /**
     Returns item identifiers for updated objects. This is mainly useful for Data Source adapters such as `UICollectionViewDiffableDataSource` or `UITableViewDiffableDataSource` which work on collection diffs when reloading. Since objects with same IDs resolve as "equal" in their old and new states, adapters may need extra heuristics to determine which row items need reloading. If your row items are all observing changes from each corresponding `ObjectPublisher`, or if you are using CoreStore's built-in `DiffableDataSource`s, there is no need to inspect this property.
     */
    public var updatedItemIdentifiers: Set<NSManagedObjectID> {

        return self.diffableSnapshot.updatedItemIdentifiers
    }

    /**
     The number of items in all sections in the `ListSnapshot`
     */
    public var numberOfItems: Int {

        return self.diffableSnapshot.numberOfItems
    }

    /**
     The number of sections in the `ListSnapshot`
     */
    public var numberOfSections: Int {

        return self.diffableSnapshot.numberOfSections
    }

    /**
     Returns the number of items for the specified `SectionID`.

     - parameter sectionID: the `SectionID`. Specifying an invalid value will raise an exception.
     - returns: The number of items in the given `SectionID`
     */
    public func numberOfItems(inSectionWithID sectionID: SectionID) -> Int {

        return self.diffableSnapshot.numberOfItems(inSection: sectionID)
    }

    /**
     Returns the number of items at the specified section index.

     - parameter sectionIndex: the index of the section. Specifying an invalid value will raise an exception.
     - returns: The number of items in the given `SectionID`
     */
    public func numberOfItems(inSectionIndex sectionIndex: Int) -> Int {

        let snapshot = self.diffableSnapshot
        let sectionID = snapshot.sectionIdentifiers[sectionIndex]
        return snapshot.numberOfItems(inSection: sectionID)
    }

    /**
     All section identifiers in the `ListSnapshot`
     */
    public var sectionIDs: [SectionID] {

        return self.diffableSnapshot.sectionIdentifiers
    }

    /**
     Returns the `SectionID` that the specified `ItemID` belongs to, or `nil` if it is not in the list.

     - parameter itemID: the `ItemID`
     - returns: the `SectionID` that the specified `ItemID` belongs to, or `nil` if it is not in the list
     */
    public func sectionID(containingItemWithID itemID: ItemID) -> SectionID? {

        return self.diffableSnapshot.sectionIdentifier(containingItem: itemID)
    }

    /**
     All object identifiers in the `ListSnapshot`
     */
    public var itemIDs: [ItemID] {

        return self.diffableSnapshot.itemIdentifiers
    }

    /**
     Returns the item identifiers belonging to the specified `SectionID`.

     - parameter sectionID: the `SectionID`. Specifying an invalid value will raise an exception.
     - returns: the `ItemID` array belonging to the given `SectionID`
     */
    public func itemIDs(inSectionWithID sectionID: SectionID) -> [ItemID] {

        return self.diffableSnapshot.itemIdentifiers(inSection: sectionID)
    }

    /**
     Returns the item identifiers belonging to the specified `SectionID` and a `Sequence` of item indices.

     - parameter sectionID: the `SectionID`. Specifying an invalid value will raise an exception.
     - parameter indices: the positions of the itemIDs to return. Specifying an invalid value will raise an exception.
     - returns: the `ItemID` array belonging to the given `SectionID` at the specified indices
     */
    public func itemIDs<S: Sequence>(inSectionWithID sectionID: SectionID, atIndices indices: S) -> [ItemID] where S.Element == Int {

        let itemIDs = self.diffableSnapshot.itemIdentifiers(inSection: sectionID)
        return indices.map({ itemIDs[$0] })
    }

    /**
     Returns the index of the specified `ItemID` in the whole list, or `nil` if it is not in the list.

     - parameter itemID: the `ItemID`
     - returns: the index of the specified `ItemID`, or `nil` if it is not in the list
     */
    public func indexOfItem(withID itemID: ItemID) -> Index? {

        return self.diffableSnapshot.indexOfItem(itemID)
    }

    /**
     Returns the index of the specified `SectionID`, or `nil` if it is not in the list.

     - parameter sectionID: the `SectionID`
     - returns: the index of the specified `SectionID`, or `nil` if it is not in the list
     */
    public func indexOfSection(withID sectionID: SectionID) -> Int? {

        return self.diffableSnapshot.indexOfSection(sectionID)
    }

    /**
     Returns an array of `ObjectPublisher`s for the items at the specified indices

     - parameter indices: the positions of items. Specifying an invalid value will raise an exception.
     - returns: an array of `ObjectPublisher`s for the items at the specified indices
     */
    public func items<S: Sequence>(atIndices indices: S) -> [ObjectPublisher<O>] where S.Element == Index {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIdentifiers
        return indices.map { position in

            let itemID = itemIDs[position]
            return context.objectPublisher(objectID: itemID)
        }
    }

    /**
     Returns an array of `ObjectPublisher`s for the items in the specified `SectionID`

     - parameter sectionID: the `SectionID`. Specifying an invalid value will raise an exception.
     - returns: an array of `ObjectPublisher`s for the items in the specified `SectionID`
     */
    public func items(inSectionWithID sectionID: SectionID) -> [ObjectPublisher<O>] {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIdentifiers(inSection: sectionID)
        return itemIDs.map(context.objectPublisher(objectID:))
    }

    /**
     Returns an array of `ObjectPublisher`s for the items in the specified `SectionID` and indices

     - parameter sectionID: the `SectionID`. Specifying an invalid value will raise an exception.
     - parameter itemIndices: the positions of items within the section. Specifying an invalid value will raise an exception.
     - returns: an array of `ObjectPublisher`s for the items in the specified `SectionID` and indices
     */
    public func items<S: Sequence>(inSectionWithID sectionID: SectionID, atIndices itemIndices: S) -> [ObjectPublisher<O>] where S.Element == Int {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIdentifiers(inSection: sectionID)
        return itemIndices.map { position in

            let itemID = itemIDs[position]
            return context.objectPublisher(objectID: itemID)
        }
    }

    /**
     Returns a lazy sequence of `ObjectPublisher`s for the items at the specified indices

     - parameter indices: the positions of items. Specifying an invalid value will raise an exception.
     - returns: a lazy sequence of `ObjectPublisher`s for the items at the specified indices
     */
    public func lazy<S: Sequence>(atIndices indices: S) -> LazyMapSequence<S, ObjectPublisher<O>> where S.Element == Index {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIdentifiers
        return indices.lazy.map { position in

            let itemID = itemIDs[position]
            return context.objectPublisher(objectID: itemID)
        }
    }

    /**
     Returns a lazy sequence of `ObjectPublisher`s for the items in the specified `SectionID`

     - parameter sectionID: the `SectionID`. Specifying an invalid value will raise an exception.
     - returns: a lazy sequence of `ObjectPublisher`s for the items in the specified `SectionID`
     */
    public func lazy(inSectionWithID sectionID: SectionID) -> LazyMapSequence<[NSManagedObjectID], ObjectPublisher<O>> {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIdentifiers(inSection: sectionID)
        return itemIDs.lazy.map(context.objectPublisher(objectID:))
    }

    /**
     Returns a lazy sequence of `ObjectPublisher`s for the items in the specified `SectionID` and indices

     - parameter sectionID: the `SectionID`. Specifying an invalid value will raise an exception.
     - parameter itemIndices: the positions of items within the section. Specifying an invalid value will raise an exception.
     - returns: a lazy sequence of `ObjectPublisher`s for the items in the specified `SectionID` and indices
     */
    public func lazy<S: Sequence>(inSectionWithID sectionID: SectionID, atIndices itemIndices: S) -> LazyMapSequence<S, ObjectPublisher<O>> where S.Element == Int {

        let context = self.context!
        let itemIDs = self.diffableSnapshot.itemIdentifiers(inSection: sectionID)
        return itemIndices.lazy.map { position in

            let itemID = itemIDs[position]
            return context.objectPublisher(objectID: itemID)
        }
    }


    // MARK: Public (Mutators)
    
    /**
     Appends extra items to the specified section

     - parameter itemIDs: the object identifiers for the objects to append
     - parameter sectionID: the section to append the items to
     */
    public mutating func appendItems<C: Collection>(withIDs itemIDs: C, toSectionWithID sectionID: SectionID? = nil) where C.Element == ItemID {

        self.diffableSnapshot.appendItems(itemIDs, toSection: sectionID)
    }
    
    /**
     Inserts extra items before a specified item

     - parameter itemIDs: the object identifiers for the objects to insert
     - parameter beforeItemID: an existing identifier to insert items before of. Specifying an invalid value will raise an exception.
     */
    public mutating func insertItems<C: Collection>(withIDs itemIDs: C, beforeItemID: ItemID) where C.Element == ItemID {

        self.diffableSnapshot.insertItems(itemIDs, beforeItem: beforeItemID)
    }
    
    /**
     Inserts extra items after a specified item

     - parameter itemIDs: the object identifiers for the objects to insert
     - parameter beforeItemID: an existing identifier to insert items after of. Specifying an invalid value will raise an exception.
     */
    public mutating func insertItems<C: Collection>(withIDs itemIDs: C, afterItemID: ItemID) where C.Element == ItemID {

        self.diffableSnapshot.insertItems(itemIDs, afterItem: afterItemID)
    }
    
    /**
     Deletes the specified items

     - parameter itemIDs: the object identifiers for the objects to delete
     */
    public mutating func deleteItems<S: Sequence>(withIDs itemIDs: S) where S.Element == ItemID {

        self.diffableSnapshot.deleteItems(itemIDs)
    }
    
    /**
     Deletes all items
     */
    public mutating func deleteAllItems() {

        self.diffableSnapshot.deleteAllItems()
    }
    
    /**
     Moves an item before another specified item

     - parameter itemID: an object identifier in the list to move. Specifying an invalid value will raise an exception.
     - parameter beforeItemID: another identifier to move the item before of. Specifying an invalid value will raise an exception.
     */
    public mutating func moveItem(withID itemID: ItemID, beforeItemID: ItemID) {

        self.diffableSnapshot.moveItem(itemID, beforeItem: beforeItemID)
    }
    
    /**
     Moves an item after another specified item

     - parameter itemID: an object identifier in the list to move. Specifying an invalid value will raise an exception.
     - parameter beforeItemID: another identifier to move the item after of. Specifying an invalid value will raise an exception.
     */
    public mutating func moveItem(withID itemID: ItemID, afterItemID: ItemID) {

        self.diffableSnapshot.moveItem(itemID, afterItem: afterItemID)
    }
    
    /**
     Marks the specified items as reloaded

     - parameter itemIDs: the object identifiers to reload
     */
    public mutating func reloadItems<S: Sequence>(withIDs itemIDs: S) where S.Element == ItemID {

        self.diffableSnapshot.reloadItems(itemIDs)
    }
    
    /**
     Appends new section identifiers to the end of the list

     - parameter sectionIDs: the sections to append
     */
    public mutating func appendSections<C: Collection>(withIDs sectionIDs: C) where C.Element == SectionID {

        self.diffableSnapshot.appendSections(sectionIDs)
    }
    
    /**
     Inserts new sections before an existing section

     - parameter sectionIDs: the section identifiers for the sections to insert
     - parameter beforeSectionID: an existing identifier to insert items before of. Specifying an invalid value will raise an exception.
     */
    public mutating func insertSections<C: Collection>(withIDs sectionIDs: C, beforeSectionID: SectionID) where C.Element == SectionID {

        self.diffableSnapshot.insertSections(sectionIDs, beforeSection: beforeSectionID)
    }
    
    /**
     Inserts new sections after an existing section

     - parameter sectionIDs: the section identifiers for the sections to insert
     - parameter beforeSectionID: an existing identifier to insert items after of. Specifying an invalid value will raise an exception.
     */
    public mutating func insertSections<C: Collection>(withIDs sectionIDs: C, afterSectionID: SectionID) where C.Element == SectionID {

        self.diffableSnapshot.insertSections(sectionIDs, afterSection: afterSectionID)
    }
    
    /**
     Deletes the specified sections

     - parameter sectionIDs: the section identifiers for the sections to delete
     */
    public mutating func deleteSections<S: Sequence>(withIDs sectionIDs: S) where S.Element == SectionID {

        self.diffableSnapshot.deleteSections(sectionIDs)
    }
    
    /**
     Moves a section before another specified section

     - parameter sectionID: a section identifier in the list to move. Specifying an invalid value will raise an exception.
     - parameter beforeSectionID: another identifier to move the section before of. Specifying an invalid value will raise an exception.
     */
    public mutating func moveSection(withID sectionID: SectionID, beforeSectionID: SectionID) {

        self.diffableSnapshot.moveSection(sectionID, beforeSection: beforeSectionID)
    }
    
    /**
     Moves a section after another specified section

     - parameter sectionID: a section identifier in the list to move. Specifying an invalid value will raise an exception.
     - parameter afterSectionID: another identifier to move the section after of. Specifying an invalid value will raise an exception.
     */
    public mutating func moveSection(withID sectionID: SectionID, afterSectionID: SectionID) {

        self.diffableSnapshot.moveSection(sectionID, afterSection: afterSectionID)
    }
    
    /**
     Marks the specified sections as reloaded

     - parameter sectionIDs: the section identifiers to reload
     */
    public mutating func reloadSections<S: Sequence>(withIDs sectionIDs: S) where S.Element == SectionID {

        self.diffableSnapshot.reloadSections(sectionIDs)
    }

    
    
    // MARK: RandomAccessCollection
    
    public var startIndex: Index {
        
        return self.diffableSnapshot.itemIdentifiers.startIndex
    }
    
    public var endIndex: Index {
        
        return self.diffableSnapshot.itemIdentifiers.endIndex
    }
    
    
    // MARK: Sequence
    
    public typealias Element = ObjectPublisher<O>
    
    public typealias Index = Int
    
    
    // MARK: Equatable
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        
        return lhs.id == rhs.id
    }
    
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(self.id)
    }
    
    
    // MARK: Internal
    
    internal private(set) var diffableSnapshot: Internals.DiffableDataSourceSnapshot
    
    internal init() {

        self.diffableSnapshot = Internals.DiffableDataSourceSnapshot()
        self.context = nil
    }
    
    internal init(diffableSnapshot: Internals.DiffableDataSourceSnapshot, context: NSManagedObjectContext) {

        self.diffableSnapshot = diffableSnapshot
        self.context = context
    }
    
    
    // MARK: Private
    
    private let id: UUID = .init()
    private let context: NSManagedObjectContext?

}
