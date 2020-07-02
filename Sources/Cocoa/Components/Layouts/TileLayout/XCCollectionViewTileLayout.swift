//
// Xcore
// Copyright © 2019 Xcore
// MIT license, see LICENSE file for details
//

import UIKit

extension XCCollectionViewTileLayout {
    public struct SectionConfiguration {
        /// Enables tile effect for each section.
        /// The default value is `true`.
        public var isTileEnabled: Bool

        /// In a multi-column, setup returning `false` will make this section to be full
        /// width instead of column width.
        public var isFullWidth: Bool

        /// The corner radius applied to the section tile.
        public var cornerRadius: CGFloat

        /// Displays a shadow behind the section tile.
        public var isShadowEnabled: Bool

        /// Return a not null identifier to link this section with other ones, this will
        /// make the items of this section to appear and disappear from the first item
        /// that appears on the group.
        ///
        /// This can used for stacking of sections.
        public var parentIdentifier: String?

        /// Space between the section and the next section, is not applied for section
        /// with no items.
        public var bottomSpacing: CGFloat

        /// Spacing on top before section starts when placed on top of all the sections in the column.
        public var topTileSpacing: CGFloat

        /// Apply an alpha to all elements of the datasource.
        public var shouldDimElements: Bool

        public init(
            isTileEnabled: Bool = true,
            isFullWidth: Bool = false,
            cornerRadius: CGFloat = 11,
            isShadowEnabled: Bool = true,
            parentIdentifier: String? = nil,
            bottomSpacing: CGFloat = .defaultPadding,
            topTileSpacing: CGFloat = .defaultPadding,
            shouldDimElements: Bool = false
        ) {
            self.isTileEnabled = isTileEnabled
            self.isFullWidth = isFullWidth
            self.cornerRadius = cornerRadius
            self.isShadowEnabled = isShadowEnabled
            self.parentIdentifier = parentIdentifier
            self.bottomSpacing = bottomSpacing
            self.topTileSpacing = topTileSpacing
            self.shouldDimElements = shouldDimElements
        }
    }

    private struct LayoutElements {
        var attributesBySection: [[Attributes]]
        var layoutAttributes: [IndexPath: Attributes]
        var footerAttributes: [IndexPath: Attributes]
        var headerAttributes: [IndexPath: Attributes]
        var sectionBackgroundAttributes: [IndexPath: Attributes]
        var firstParentIndexByIdentifier: [String: Int]

        // Elements in rect calculation
        var sectionRects: [CGRect]
        var sectionIndexesByColumn: [[Int]]
    }
}

open class XCCollectionViewTileLayout: UICollectionViewLayout, DimmableLayout {
    private let UICollectionElementKindSectionBackground = "UICollectionElementKindSectionBackground"
    public var defaultSectionConfiguration = SectionConfiguration() {
        didSet {
            shouldReloadAttributes = true
            invalidateLayout()
        }
    }

    public var numberOfColumns = 1 {
        didSet {
            shouldReloadAttributes = true
            invalidateLayout()
        }
    }

    public var horizontalMargin: CGFloat = .minimumPadding {
        didSet {
            shouldReloadAttributes = true
            invalidateLayout()
        }
    }

    public var interColumnSpacing: CGFloat = .defaultPadding {
        didSet {
            shouldReloadAttributes = true
            invalidateLayout()
        }
    }

    /// A boolean property to determine whether every collection view element is dimmed.
    public var shouldDimElements: Bool = false

    public var estimatedItemHeight: CGFloat = 200
    public var estimatedHeaderFooterHeight: CGFloat = 44

    private var cachedContentSize: CGSize = .zero
    public var shouldReloadAttributes = true
    private var minimumItemZIndex: Int = 0

    // Layout Elements
    private var attributesBySection = [[Attributes]]()
    private var layoutAttributes = [IndexPath: Attributes]()
    private var footerAttributes = [IndexPath: Attributes]()
    private var headerAttributes = [IndexPath: Attributes]()
    private var sectionBackgroundAttributes = [IndexPath: Attributes]()
    private var firstParentIndexByIdentifier = [String: Int]()

    // Elements in rect calculation
    private var sectionRects = [CGRect]()
    private var sectionIndexesByColumn = [[Int]]()

    private var beforeElements: LayoutElements?

    open override class var layoutAttributesClass: AnyClass {
        Attributes.self
    }

    public override init() {
        super.init()
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        register(XCCollectionViewTileBackgroundView.self, forDecorationViewOfKind: UICollectionElementKindSectionBackground)
    }

    open override func prepare() {
        super.prepare()

        guard !shouldReloadAttributes else {
            shouldReloadAttributes = false

            beforeElements = LayoutElements(
                attributesBySection: attributesBySection,
                layoutAttributes: layoutAttributes,
                footerAttributes: footerAttributes,
                headerAttributes: headerAttributes,
                sectionBackgroundAttributes: sectionBackgroundAttributes,
                firstParentIndexByIdentifier: firstParentIndexByIdentifier,
                sectionRects: sectionRects,
                sectionIndexesByColumn: sectionIndexesByColumn
            )

            attributesBySection.removeAll()
            layoutAttributes.removeAll()
            footerAttributes.removeAll()
            headerAttributes.removeAll()
            sectionBackgroundAttributes.removeAll()
            firstParentIndexByIdentifier.removeAll()
            sectionRects.removeAll()

            cachedContentSize = .zero
            calculateAttributes()
            return
        }
    }

    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        if context.invalidateEverything || context.invalidateDataSourceCounts {
            shouldReloadAttributes = true
        }
        super.invalidateLayout(with: context)
    }

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }

        if newBounds.size != collectionView.bounds.size {
            shouldReloadAttributes = true
            return true
        }

        return false
    }

    private func calculateAttributes(shouldCreateAttributes: Bool = true) {
        guard let collectionView = self.collectionView else { return }
        let contentWidth: CGFloat = collectionView.bounds.width - horizontalMargin * 2.0
        let columnWidth = (contentWidth - (interColumnSpacing * CGFloat(numberOfColumns - 1))) / CGFloat(numberOfColumns)

        var offset: CGPoint = .zero
        var itemCount: Int = 0
        var currentColumn: Int = 0
        var itemWidth: CGFloat = 0
        var margin: CGFloat = 0

        var sectionConfiguration: SectionConfiguration
        var columnYOffset = [CGFloat](repeating: 0, count: numberOfColumns)

        sectionIndexesByColumn.removeAll()
        for _ in 0..<numberOfColumns {
            sectionIndexesByColumn.append([Int]())
        }

        var zIndex = 0
        for section in 0..<collectionView.numberOfSections {
            let isTopSection = minColumn(columnYOffset).height == 0.0
            sectionConfiguration = configuration(forSectionAt: section)

            itemCount = collectionView.numberOfItems(inSection: section)

            if numberOfColumns > 1 {
                currentColumn = sectionConfiguration.isFullWidth ? minColumn(columnYOffset).index : maxColumn(columnYOffset).index
            }

            itemWidth = !sectionConfiguration.isFullWidth ? columnWidth : collectionView.frame.size.width
            margin = !sectionConfiguration.isFullWidth ? horizontalMargin : 0

            sectionIndexesByColumn[currentColumn].append(section)

            offset.x = !sectionConfiguration.isFullWidth ? (itemWidth + interColumnSpacing) * CGFloat(currentColumn) + margin : 0
            offset.y = columnYOffset[currentColumn]

            if itemCount > 0 && isTopSection {
                offset.y += sectionConfiguration.topTileSpacing
            }

            let initialRect = CGRect(origin: offset, size: CGSize(width: itemWidth, height: 0))
            let sectionRect = createAttributes(
                for: section,
                rect: initialRect,
                itemCount: itemCount,
                zIndex: zIndex,
                alpha: 1.0,
                sectionConfiguration: sectionConfiguration
            )
            // Update height of section rect
            sectionRects.append(sectionRect)
            zIndex -= 1
            createBackgroundAttributes(for: section, zIndex: zIndex, alpha: 1.0, sectionConfiguration: sectionConfiguration)

            offset.y += sectionRects[section].height

            if itemCount > 0 {
                // Add bottom spacing
                offset.y += offset.y > 0 ? sectionConfiguration.bottomSpacing : 0
            }

            if let identifier = sectionConfiguration.parentIdentifier {
                if firstParentIndexByIdentifier[identifier] == nil {
                    firstParentIndexByIdentifier[identifier] = section
                }
            }

            if sectionConfiguration.isTileEnabled {
                columnYOffset[currentColumn] = offset.y
            } else {
                for i in 0..<columnYOffset.count {
                    columnYOffset[i] = offset.y
                }
            }
        }

        cachedContentSize = CGSize(width: collectionView.bounds.width, height: self.maxColumn(columnYOffset).height)
    }

    private func createAttributes(for section: Int, rect: CGRect, itemCount: Int, zIndex: Int = 0, alpha: CGFloat, sectionConfiguration: SectionConfiguration) -> CGRect {
        var sectionRect = rect
        var sectionAttributes = [Attributes]()
        guard itemCount > 0 else {
            attributesBySection.append(sectionAttributes)
            return sectionRect
        }

        let headerInfo = headerAttributes(in: section, width: sectionRect.width)
        let footerInfo = footerAttributes(in: section, width: sectionRect.width)

        if headerInfo.enabled {
            let headerIndex = IndexPath(item: 0, section: section)
            let attributes = Attributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                with: headerIndex
            ).apply {
                $0.frame = CGRect(
                    x: sectionRect.origin.x,
                    y: sectionRect.maxY,
                    width: sectionRect.width,
                    height: headerInfo.height ?? estimatedHeaderHeight(in: section, width: sectionRect.width)
                )

                $0.corners = sectionConfiguration.isTileEnabled ? (.top, sectionConfiguration.cornerRadius) : (.none, 0)
                $0.shouldDim = shouldDimElements || sectionConfiguration.shouldDimElements
                $0.zIndex = zIndex
                $0.alpha = alpha
                $0.parentIdentifier = sectionConfiguration.parentIdentifier
                $0.offsetInSection = sectionRect.height
            }

            headerAttributes[headerIndex] = attributes
            sectionRect.size.height += attributes.size.height
            sectionAttributes.append(attributes)
        }

        var indexPath = IndexPath(item: 0, section: section)
        var fixedHeight: CGFloat?
        for item in 0..<itemCount {
            indexPath.item = item
            fixedHeight = height(forItemAt: indexPath, width: sectionRect.width)
            let attributes = Attributes(forCellWith: indexPath).apply {
                $0.frame = CGRect(
                    x: sectionRect.origin.x,
                    y: sectionRect.maxY,
                    width: sectionRect.width,
                    height: fixedHeight ?? estimatedHeight(forItemAt: indexPath, width: sectionRect.width)
                )

                if sectionConfiguration.isTileEnabled {
                    var corners: CACornerMask = .none
                    if !headerInfo.enabled, item == 0 {
                        corners.formUnion(.top)
                    }
                    if !footerInfo.enabled, item == itemCount - 1 {
                        corners.formUnion(.bottom)
                    }
                    $0.corners = (corners, sectionConfiguration.cornerRadius)
                } else {
                    $0.corners = (.none, 0)
                }

                $0.shouldDim = shouldDimElements || sectionConfiguration.shouldDimElements
                $0.zIndex = zIndex
                $0.alpha = alpha
                $0.parentIdentifier = sectionConfiguration.parentIdentifier
                $0.offsetInSection = sectionRect.height
            }
            layoutAttributes[indexPath] = attributes
            sectionRect.size.height += attributes.size.height
            sectionAttributes.append(attributes)
        }

        if footerInfo.enabled {
            let footerIndex = IndexPath(item: 0, section: section)
            let attributes = Attributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                with: footerIndex
            ).apply {
                $0.frame = CGRect(
                    x: sectionRect.origin.x,
                    y: sectionRect.maxY,
                    width: sectionRect.width,
                    height: footerInfo.height ?? estimatedFooterHeight(in: section, width: sectionRect.width)
                )
                $0.corners = sectionConfiguration.isTileEnabled ? (.bottom, sectionConfiguration.cornerRadius) : (.none, 0)
                $0.shouldDim = shouldDimElements || sectionConfiguration.shouldDimElements
                $0.zIndex = zIndex
                $0.alpha = alpha
                $0.parentIdentifier = sectionConfiguration.parentIdentifier
                $0.offsetInSection = sectionRect.height
            }
            footerAttributes[footerIndex] = attributes
            sectionRect.size.height += attributes.size.height
            sectionAttributes.append(attributes)
        }
        attributesBySection.append(sectionAttributes)
        return sectionRect
    }

    private func createBackgroundAttributes(for section: Int, zIndex: Int, alpha: CGFloat, sectionConfiguration: SectionConfiguration) {
        guard
            sectionConfiguration.isShadowEnabled,
            sectionConfiguration.isTileEnabled,
            !sectionRects[section].isEmpty
        else {
            return
        }

        let indexPath = IndexPath(item: 0, section: section)
        let attributes = sectionBackgroundAttributes[indexPath] ?? Attributes(
            forDecorationViewOfKind: UICollectionElementKindSectionBackground,
            with: indexPath
        ).apply {
            $0.corners = (.all, sectionConfiguration.cornerRadius)
            $0.zIndex = (attributesBySection[section].first?.zIndex ?? 0 ) - 1
            $0.shouldDim = shouldDimElements || sectionConfiguration.shouldDimElements
            $0.frame = sectionRects[section]
            $0.zIndex = zIndex
            $0.alpha = alpha
            $0.parentIdentifier = sectionConfiguration.parentIdentifier
        }
        sectionBackgroundAttributes[indexPath] = attributes
    }

    open override var collectionViewContentSize: CGSize {
        .init(width: cachedContentSize.width, height: cachedContentSize.height)
    }

    private func yAxisIntersection(element1: CGRect, element2: CGRect) -> ComparisonResult {
        if element1.maxY >= element2.minY, element2.maxY >= element1.minY {
            return .orderedSame
        }
        if element1.minY <= element2.minY {
            return .orderedAscending
        } else {
            return .orderedDescending
        }
    }

    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var elementsInRect = [Attributes]()

        for sectionsInColumn in sectionIndexesByColumn {
            guard let closestCandidateIndex = sectionsInColumn.binarySearch(
                target: rect,
                transform: { sectionRects[$0] },
                yAxisIntersection
            ) else {
                continue
            }

            // Look Sections Below Candidate
            for sectionIndex in sectionsInColumn[..<closestCandidateIndex].reversed() {
                guard addAttributesOf(section: sectionIndex, within: rect, in: &elementsInRect) else {
                    break
                }
            }

            // Look Sections Under Candidate
            for sectionIndex in sectionsInColumn[closestCandidateIndex...] {
                guard addAttributesOf(section: sectionIndex, within: rect, in: &elementsInRect) else {
                    break
                }
            }
        }
        return elementsInRect
    }

    private func addAttributesOf(section sectionIndex: Int, within rect: CGRect, in elementsInRect: inout [Attributes]) -> Bool {
        let sectionRect = sectionRects[sectionIndex]
        guard yAxisIntersection(element1: rect, element2: sectionRect) == .orderedSame else {
            return false
        }
        elementsInRect.append(contentsOf: attributesBySection[sectionIndex])
        if let backgroundAttributes = sectionBackgroundAttributes[IndexPath(item: 0, section: sectionIndex)] {
            elementsInRect.append(backgroundAttributes)
        }
        return true
    }

    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        layoutAttributes[indexPath]
    }

    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item == 0 else { return nil }
        switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return headerAttributes[indexPath]
            case UICollectionView.elementKindSectionFooter:
                return footerAttributes[indexPath]
            default:
                return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        }
    }

    open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item == 0 else { return nil }
        switch elementKind {
            case UICollectionElementKindSectionBackground:
                return sectionBackgroundAttributes[indexPath]
            default:
                return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
        }
    }

    private func updateFinalStackAttributes(attributes: Attributes) -> Attributes {
        guard let beforeElements = beforeElements else {
            return attributes
        }
        // Stacked items go to their parents origin
        if
            let parentIdentifier = attributes.parentIdentifier,
            let parentSectionIndex = beforeElements.firstParentIndexByIdentifier[parentIdentifier]
        {
            attributes.frame.origin.y = sectionRects[parentSectionIndex].origin.y + attributes.offsetInSection
            attributes.alpha = 0
        }
        return attributes
    }

    private func updateInitialStackAttributes(attributes: Attributes, indexPath: IndexPath) -> Attributes {
        guard let beforeElements = beforeElements else {
            return attributes
        }
        if
            let parentIdentifier = attributes.parentIdentifier,
            let parentSectionIndex = firstParentIndexByIdentifier[parentIdentifier]
        {
            attributes.frame.origin.y = beforeElements.sectionRects[parentSectionIndex].origin.y + attributes.offsetInSection
            attributes.alpha = parentSectionIndex == indexPath.section ? 1.0 : 0.0
            return attributes
        }
        return attributes
    }

    open override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) as? Attributes else {
            return nil
        }
        return updateFinalStackAttributes(attributes: attributes)
    }

    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) as? Attributes else {
            return nil
        }
        return updateInitialStackAttributes(attributes: attributes, indexPath: itemIndexPath)
    }

    open override func finalLayoutAttributesForDisappearingDecorationElement(ofKind elementKind: String, at decorationIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingDecorationElement(ofKind: elementKind, at: decorationIndexPath) as? Attributes else {
            return nil
        }
        return updateFinalStackAttributes(attributes: attributes)
    }

    open override func initialLayoutAttributesForAppearingDecorationElement(ofKind elementKind: String, at decorationIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingDecorationElement(ofKind: elementKind, at: decorationIndexPath) as? Attributes else {
            return nil
        }
        return updateInitialStackAttributes(attributes: attributes, indexPath: decorationIndexPath)
    }

    open override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath) as? Attributes else {
            return nil
        }
        return updateFinalStackAttributes(attributes: attributes)
    }

    open override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath) as? Attributes else {
            return nil
        }
        return updateInitialStackAttributes(attributes: attributes, indexPath: elementIndexPath)
    }
}

extension XCCollectionViewTileLayout {
    private var columnsHeight: [CGFloat] {
        var columnHeights = [CGFloat]()
        for columnSectionIndexes in sectionIndexesByColumn {
            if let lastIndex = columnSectionIndexes.last {
                columnHeights.append(sectionRects[lastIndex].maxY)
            }
        }
        return columnHeights
    }

    private func minColumn(_ columns: [CGFloat]) -> (index: Int, height: CGFloat) {
        var index = 0
        var minYOffset = CGFloat.infinity
        for (i, columnOffset) in columns.enumerated() where columnOffset < minYOffset {
            minYOffset = columnOffset
            index = i
        }
        return (index, minYOffset)
    }

    private func maxColumn(_ columns: [CGFloat]) -> (index: Int, height: CGFloat) {
        var index = 0
        var maxYOffset: CGFloat = -1.0
        for (i, columnOffset) in columns.enumerated() where columnOffset > maxYOffset {
            maxYOffset = columnOffset
            index = i
        }
        return (index, maxYOffset)
    }

    private func getStoredAttribute(from originalAttributes: UICollectionViewLayoutAttributes) -> Attributes? {
        switch originalAttributes.representedElementCategory {
            case .cell:
                return layoutAttributes[originalAttributes.indexPath]
            case .supplementaryView:
                switch originalAttributes.representedElementKind {
                case UICollectionView.elementKindSectionHeader:
                    return headerAttributes[originalAttributes.indexPath]
                case UICollectionView.elementKindSectionFooter:
                    return footerAttributes[originalAttributes.indexPath]
                default:
                    return nil
                }
            default:
                return nil
        }
    }
}

extension XCCollectionViewTileLayout {
    var delegate: XCCollectionViewDelegateTileLayout? {
        collectionView?.delegate as? XCCollectionViewDelegateTileLayout
    }

    private func height(forItemAt indexPath: IndexPath, width: CGFloat) -> CGFloat? {
        guard
            let collectionView = collectionView,
            let delegate = delegate
        else {
            return nil
        }

        return delegate.collectionView(collectionView, layout: self, heightForItemAt: indexPath, width: width)
    }

    private func headerAttributes(in section: Int, width: CGFloat) -> (enabled: Bool, height: CGFloat?) {
        guard
            let collectionView = collectionView,
            let delegate = delegate
        else {
            return (false, nil)
        }

        return delegate.collectionView(collectionView, layout: self, headerAttributesInSection: section, width: width)
    }

    private func footerAttributes(in section: Int, width: CGFloat) -> (enabled: Bool, height: CGFloat?) {
        guard
            let collectionView = collectionView,
            let delegate = delegate
        else {
            return (false, nil)
        }

        return delegate.collectionView(collectionView, layout: self, footerAttributesInSection: section, width: width)
    }

    private func estimatedHeight(forItemAt indexPath: IndexPath, width: CGFloat) -> CGFloat {
        guard
            let collectionView = collectionView,
            let delegate = delegate
        else {
            return estimatedItemHeight
        }

        return delegate.collectionView(collectionView, layout: self, estimatedHeightForItemAt: indexPath, width: width)
    }

    private func estimatedHeaderHeight(in section: Int, width: CGFloat) -> CGFloat {
        guard
            let collectionView = collectionView,
            let delegate = delegate
        else {
            return estimatedHeaderFooterHeight
        }

        return delegate.collectionView(collectionView, layout: self, estimatedHeaderHeightInSection: section, width: width)
    }

    private func estimatedFooterHeight(in section: Int, width: CGFloat) -> CGFloat {
        guard
            let collectionView = collectionView,
            let delegate = delegate
        else {
            return estimatedHeaderFooterHeight
        }

        return delegate.collectionView(collectionView, layout: self, estimatedFooterHeightInSection: section, width: width)
    }

    private func configuration(forSectionAt section: Int) -> SectionConfiguration {
        guard
            let collectionView = collectionView,
            let delegate = delegate
        else {
            return defaultSectionConfiguration
        }
        return delegate.collectionView(collectionView, layout: self, sectionConfigurationAt: section) ?? defaultSectionConfiguration
    }
}
