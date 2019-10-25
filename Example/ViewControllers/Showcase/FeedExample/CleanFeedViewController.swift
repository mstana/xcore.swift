//
//  CleanFeedViewController.swift
//  Haring
//
//  Created by Marek Stana on 24/10/2019.
//

import UIKit

class TextCell: UICollectionViewCell {
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        titleLabel.frame = contentView.bounds
        titleLabel.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layoutIfNeeded()
    }
}

class HeaderView: UICollectionReusableView {
    // TODO add title and button + action out
    let leftItem = UILabel()
    let rightItem = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(leftItem)
        addSubview(rightItem)
        leftItem.textAlignment = .left
        rightItem.titleLabel?.textAlignment = .right
        rightItem.setTitleColor(.blue, for: .normal)
        rightItem.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc
    private func buttonTapped() {
        print("tapped")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        leftItem.frame = bounds
        rightItem.frame = bounds
    }
}


class ShadowView: UICollectionReusableView {
    // TODO add title and button + action out
    let leftItem = UILabel()
    let rightItem = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .blue
        addSubview(leftItem)
        addSubview(rightItem)
        leftItem.textAlignment = .left
        rightItem.titleLabel?.textAlignment = .right
        rightItem.setTitleColor(.blue, for: .normal)
        rightItem.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc
    private func buttonTapped() {
        print("tapped")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        leftItem.frame = bounds
        rightItem.frame = bounds
    }
}

final class CleanFeedViewController : UICollectionViewController {

    var items = [0,1,2,3,4,5,6,7,8,9,10]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = .white
        self.collectionView?.register(TextCell.self, forCellWithReuseIdentifier: "PlayCell")
        self.collectionView?.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayCell", for: indexPath) as! TextCell
        cell.backgroundColor = .lightGray
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        cell.titleLabel.text = "Cell: \(indexPath.row)"
        cell.layer.cornerRadius = 5
        cell.backgroundColor = indexPath.row < 4 ? .red : .yellow
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let layout = collectionView.collectionViewLayout as? CustomLayout else {
            return
        }

//        collectionView.setCollectionViewLayout(CustomLayout(isStackEnabled: !layout.isStackEnabled), animated: true)
        print("here")
        collectionView.performBatchUpdates({
            layout.isStackEnabled.toggle()
        }, completion: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader,
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView {
            headerView.leftItem.text = "Show less ▿"
            headerView.rightItem.setTitle("Clear", for: .normal)
            return headerView
        }
        fatalError()
    }
}

class CustomLayout : UICollectionViewLayout {

    var isStackEnabled: Bool

    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight = CGFloat(0)
    private var width: CGFloat {
        return collectionView?.frame.width ?? 0
    }

    private let UICollectionElementKindSectionBackground = "UICollectionElementKindSectionBackground"
    private let UICollectionElementKindSectionShadow = "UICollectionElementKindSectionShadow"

    override var collectionViewContentSize: CGSize {
        return CGSize(width: width, height: contentHeight)
    }

    init(isStackEnabled: Bool = false) {
        self.isStackEnabled = isStackEnabled
        super.init()
        register(ShadowView.self, forDecorationViewOfKind: UICollectionElementKindSectionShadow)
    }

    required init?(coder: NSCoder) {
        self.isStackEnabled = false
        super.init(coder: coder)
        register(ShadowView.self, forDecorationViewOfKind: UICollectionElementKindSectionShadow)
    }

    override func prepare() {

        guard let collectionView = collectionView else {
            print("shit")
            return
        }

        print("prepare")

        let padding = 10
        let stackGap = 6

        if cache.isEmpty {

            let indexPath = IndexPath(item: 0, section: 0)
            let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: indexPath)
            layoutAttributes.frame = CGRect(x: 0.0, y: 10.0, width: width, height: 50)
            layoutAttributes.alpha = isStackEnabled ? 0 : 1
            layoutAttributes.transform = isStackEnabled ? CGAffineTransform(translationX: 0, y: 50) : .identity
            cache.append(layoutAttributes)

            let columWidth = width
            var y = isStackEnabled ? 0 : 70
            let itemsCounts = collectionView.numberOfItems(inSection: 0)
            for item in 0..<itemsCounts {
                let indexPath = IndexPath(item: item, section: 0)
                let columHeight = 70 + (isStackEnabled ? 0 : 10 * item)

                // TODO: Rewrite this to use bottom to stack not top!
                let frame = CGRect(x: 0, y: y, width: Int(columWidth), height: columHeight)
                y += isStackEnabled ?
                    ( item > 2 ? (columHeight + padding) : stackGap) :
                    columHeight + padding


                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                attributes.zIndex = collectionView.numberOfItems(inSection: 0) - 1 - item
                let scaling = (1.0 - ( CGFloat(item) / CGFloat(itemsCounts)/2 ))
                let alphing = item < 4 ? (1.0 - ( CGFloat(item) / CGFloat(itemsCounts) )) : 1
//                attributes.transform = isStackEnabled && (item < 4) ? CGAffineTransform(scaleX: scaling, y: scaling) : .identity
                attributes.alpha = isStackEnabled ? alphing : 1.0
                cache.append(attributes)
                contentHeight = max(contentHeight, CGFloat(y))

                let decorator = UICollectionViewLayoutAttributes(forDecorationViewOfKind: UICollectionElementKindSectionShadow, with: indexPath)
                decorator.frame = attributes.frame
                decorator.size.height += 5
                decorator.zIndex = -1
                cache.append(decorator)
            }
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributed = [UICollectionViewLayoutAttributes]()
        for attribute in cache {
            if rect.intersects(attribute.frame) {
                layoutAttributed.append(attribute)
            }
        }
        return cache
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache = []
        contentHeight = 0
    }
}
