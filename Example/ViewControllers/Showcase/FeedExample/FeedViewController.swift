//
// FeedViewController.swift
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

final class FeedViewController: XCComposedCollectionViewController {
    private var sources = [FeedDataSource]()
    private var isStackingEnabled = false {
        didSet {
            if isStackingEnabled {
                (collectionView.collectionViewLayout as? XCCollectionViewTileLayout)?.stackingState = .stacked
            } else {
                (collectionView.collectionViewLayout as? XCCollectionViewTileLayout)?.stackingState = .unstacked
            }
            collectionView.performBatchUpdates(nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        collectionView.backgroundColor = .clear
        collectionView.contentInset.top = view.safeAreaInsets.top

        recreateSources()
        layout = .init(XCCollectionViewTileLayout())

        (collectionView.collectionViewLayout as? XCCollectionViewTileLayout)?.stackItemsCount = 5
        isStackingEnabled = true
        (collectionView.collectionViewLayout as? XCCollectionViewTileLayout)?.actionHandler = { [weak self] action in
            switch action {
                case .left:
                    self?.isStackingEnabled = true
                case .right:
                    print("Right button action tapped")
            }
        }
        let item = UIBarButtonItem(title: "DO!", style: .plain, target: self, action: #selector(doIt))

        navigationItem.rightBarButtonItems = [item]
    }

    @objc
    func doIt() {
        isStackingEnabled.toggle()
    }

    override func dataSources(for collectionView: UICollectionView) -> [XCCollectionViewDataSource] {
        sources
    }

    private func recreateSources() {
        sources.removeAll()
        let sourcesCount = 50
        for _ in 0..<sourcesCount {
            let source = FeedDataSource(collectionView: collectionView)
            sources.append(source)
        }

        composedDataSource.dataSources = dataSources(for: collectionView)
        collectionView.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isStackingEnabled.toggle()
    }
}
