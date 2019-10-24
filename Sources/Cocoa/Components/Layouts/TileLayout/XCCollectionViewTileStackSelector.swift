//
//  XCCollectionViewTileStackSelector.swift
//
// Copyright © 2019 Xcore
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

final class XCCollectionViewTileStackSelector: UICollectionReusableView {
    // MARK: - Init Methods

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private lazy var leadingButton = UIButton().apply {
        $0.text = "Show less" // TODO: solve localization
        $0.action { [weak self] _ in
            self?.buttonTappedHandler?(.left)
        }
    }

    private lazy var trailingButton = UIButton().apply {
        $0.text = "Clear"  // TODO: solve localization
        $0.action { [weak self] _ in
            self?.buttonTappedHandler?(.right)
        }
    }

    private var buttonTappedHandler: ((XCCollectionViewTileLayoutAction) -> Void)?

    private func commonInit() {
        addSubview(leadingButton)
        addSubview(trailingButton)

        leadingButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(.minimumPadding)
        }
        trailingButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(.minimumPadding)
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let tileAttributes = layoutAttributes as? XCCollectionViewTileLayout.Attributes {
            buttonTappedHandler = tileAttributes.actionHandler
        }
    }
}
