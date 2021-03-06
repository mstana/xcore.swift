//
// Xcore
// Copyright © 2016 Xcore
// MIT license, see LICENSE file for details
//

// Adopted: https://medium.com/swift-programming/ce22d76f120c

import Foundation

public struct ArrayIterator<Element>: IteratorProtocol {
    private let array: [Element]
    private var currentIndex = 0

    public init(_ array: [Element]) {
        self.array = array
    }

    public mutating func next() -> Element? {
        let element = array.at(currentIndex)
        currentIndex += 1
        return element
    }
}

public struct Section<Element>: RangeReplaceableCollection, MutableCollection, ExpressibleByArrayLiteral {
    public var title: String?
    public var detail: String?
    public var items: [Element]

    public init() {
        self.title = nil
        self.detail = nil
        self.items = []
    }

    public init(arrayLiteral elements: Element...) {
        self.items = elements
    }

    public init(title: String? = nil, detail: String? = nil, items: [Element]) {
        self.title = title
        self.detail = detail
        self.items = items
    }

    public let startIndex = 0
    public var endIndex: Int {
        items.count
    }

    public subscript(index: Int) -> Element {
        get { items[index] }
        set { items[index] = newValue }
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        i + 1
    }

    public func makeIterator() -> ArrayIterator<Element> {
        .init(items)
    }

    public mutating func replaceSubrange<C: Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Element {
        items.replaceSubrange(subRange, with: newElements)
    }
}

extension Array where Element: MutableCollection, Element.Index == Int {
    /// A convenience subscript to return the element at the specified index path.
    ///
    /// - Parameter indexPath: The index path for the element.
    /// - Returns: The element at the specified index path iff it is within bounds, otherwise `fatalError`.
    public subscript(indexPath: IndexPath) -> Element.Iterator.Element {
        get { self[indexPath.section][indexPath.item] }
        set { self[indexPath.section][indexPath.item] = newValue }
    }
}

extension Array where Element: RangeReplaceableCollection, Element.Index == Int {
    /// Remove the element at the specified index path.
    ///
    /// - Parameter indexPath: The index path for the element to remove.
    /// - Returns: The removed element.
    @discardableResult
    public mutating func remove(at indexPath: IndexPath) -> Element.Iterator.Element {
        self[indexPath.section].remove(at: indexPath.item)
    }

    /// Insert newElement at the specified index path.
    ///
    /// - Parameters:
    ///   - newElement: The new element to insert.
    ///   - indexPath:  The index path to insert the element at.
    public mutating func insert(_ newElement: Element.Iterator.Element, at indexPath: IndexPath) {
        self[indexPath.section].insert(newElement, at: indexPath.item)
    }

    /// Move an element at a specific location in the `self` to another location.
    ///
    /// - Parameters:
    ///   - from: An index path locating the element to be moved in `self`.
    ///   - to:   An index path locating the element in `self` that is the destination of the move.
    /// - Returns: The moved element.
    @discardableResult
    public mutating func moveElement(from indexPath: IndexPath, to theIndexPath: IndexPath) -> Element.Iterator.Element {
        let elementToMove = remove(at: indexPath)
        insert(elementToMove, at: theIndexPath)
        return elementToMove
    }
}
