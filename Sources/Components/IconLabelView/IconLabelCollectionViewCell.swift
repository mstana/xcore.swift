//
// IconLabelCollectionViewCell.swift
//
// Copyright © 2015 Zeeshan Mian
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit

public class IconLabelCollectionViewCell: UICollectionViewCell {
    public class var reuseIdentifier: String { return "IconLabelCollectionViewCellIdentifier" }
    public let iconLabelView = IconLabelView()

    // MARK: Init Methods

    public convenience init() {
        self.init(frame: .zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    // MARK: Setters

    public func setData(data: ImageTitleDisplayable) {
        iconLabelView.setData(title: data.title, subtitle: data.subtitle)
        data.setImage(iconLabelView.imageView)
    }

    // MARK: Setup Method

    private func setupSubviews() {
        contentView.addSubview(iconLabelView)
        NSLayoutConstraint.constraintsForViewToFillSuperview(iconLabelView).activate()
        iconLabelView.userInteractionEnabled   = false
        iconLabelView.isRoundImageView         = true
        iconLabelView.imagePadding             = 0
        iconLabelView.imageBackgroundColor     = UIColor.blackColor().alpha(0.1)
        iconLabelView.imageView.borderColor    = UIColor.blackColor().alpha(0.1)
        iconLabelView.titleLabel.numberOfLines = 1
        iconLabelView.titleLabel.textColor     = UIColor.lightGrayColor()
        iconLabelView.subtitleLabel.textColor  = UIColor.lightGrayColor()
    }
}