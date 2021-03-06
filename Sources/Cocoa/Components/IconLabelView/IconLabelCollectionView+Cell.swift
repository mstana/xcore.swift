//
// Xcore
// Copyright © 2015 Xcore
// MIT license, see LICENSE file for details
//

import UIKit

extension IconLabelCollectionView {
    open class Cell: XCCollectionViewCell {
        public let iconLabelView = IconLabelView().apply {
            $0.isUserInteractionEnabled = false
            $0.isImageViewRounded = true
            $0.imageBackgroundColor = UIColor.black.alpha(0.1)
            $0.imageView.borderColor = UIColor.black.alpha(0.1)
            $0.titleLabel.numberOfLines = 1
            $0.titleLabel.textColor = .lightGray
            $0.subtitleLabel.textColor = .lightGray
        }

        private let deleteButton = UIButton().apply {
            $0.isHidden = true

            $0.image(r(.collectionViewCellDeleteIcon), for: .normal)
            $0.imageView?.cornerRadius = 24/2
            $0.imageView?.backgroundColor = .white

            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = .zero
            $0.layer.shadowOpacity = 0.3
            $0.layer.shadowRadius = 5
        }

        // MARK: Setup Method

        open override func commonInit() {
            contentView.addSubview(iconLabelView)
            iconLabelView.anchor.edges.equalToSuperview()
            setupDeleteButton()
        }

        // MARK: Delete Button

        private func setupDeleteButton() {
            contentView.addSubview(deleteButton)
            let buttonSize: CGFloat = 44
            let offset = iconLabelView.isImageViewRounded ? buttonSize / 4 : buttonSize / 2

            deleteButton.anchor.make {
                $0.size.equalTo(buttonSize)
                $0.top.equalToSuperview().inset(-offset)
                $0.trailing.equalToSuperview().inset(-offset)
            }
        }
    }
}

extension IconLabelCollectionView.Cell {
    open func configure(_ data: ImageTitleDisplayable, at indexPath: IndexPath, collectionView: IconLabelCollectionView) {
        iconLabelView.configure(data)
        setDeleteButtonHidden(!collectionView.isEditing, animated: false)
        deleteButton.action { [weak collectionView] _ in
            collectionView?.removeItems([indexPath])
        }
    }

    func setDeleteButtonHidden(_ hide: Bool, animated: Bool = true) {
        guard hide != deleteButton.isHidden else { return }

        if animated {
            if hide {
                deleteButtonZoomOut()
            } else {
                deleteButtonZoomIn()
            }
        } else {
            deleteButton.isHidden = hide
        }
    }

    private func deleteButtonZoomIn() {
        deleteButton.isHidden = false
        deleteButton.alpha = 0
        deleteButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)

        UIView.animate(withDuration: 0.2, animations: {
            self.deleteButton.alpha = 1
            self.deleteButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.deleteButton.transform = .identity
            }
        })
    }

    private func deleteButtonZoomOut() {
        UIView.animate(withDuration: 0.2, animations: {
            self.deleteButton.alpha = 0
            self.deleteButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { _ in
            self.deleteButton.isHidden = true
        })
    }
}
