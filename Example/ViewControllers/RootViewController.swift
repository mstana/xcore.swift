//
// RootViewController.swift
//
// Copyright © 2014 Xcore
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

final class RootViewController: DynamicTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sections = [
            Section(
                title: "Components",
                detail: "A demonstration of components included in Xcore.",
                items: items()
            ),
            Section(
                title: "Pickers",
                detail: "A demonstration of pickers included in Xcore.",
                items: pickers()
            )
        ]

        tableView.configureCell { indexPath, cell, item in
            cell.highlightedBackgroundColor = .appHighlightedBackground
        }
    }

    private func items() -> [DynamicTableModel] {
        return [
            .init(title: "Dynamic Table View", subtitle: "Data-driven table view", accessory: .disclosureIndicator) { [weak self] _, _ in
                let vc = ExampleDynamicTableViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            },
            .init(title: "Separators", subtitle: "Separators demonstration") { [weak self] _, _ in
                let vc = SeparatorViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            },
            .init(title: "Buttons", subtitle: "UIButton extensions demonstration") { [weak self] _, _ in
                let vc = ButtonsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            },
            .init(title: "TextViewController", subtitle: "TextViewController demonstration") { [weak self] _, _ in
                let vc = ExampleTextViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            },
            .init(title: "FeedViewController", subtitle: "FeedViewController demonstration") { [weak self] _, _ in
                let vc = FeedViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            },
            .init(title: "AlertsViewController", subtitle: "Tiled Alerts Demostration") { [weak self] _, _ in
                let vc = AlertsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            },
            .init(title: "Carousel View Controller", subtitle: "Carousel demonstration") { [weak self] _, _ in
                let vc = CarouselViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        ]
    }

    private func pickers() -> [DynamicTableModel] {
        return [
            .init(title: "DatePicker", subtitle: "Date picker demonstration, selected value yesterday") { _, _ in
                let yesterday = Date(timeIntervalSinceNow: -3600 * 24)
                DatePicker.present(initialValue: yesterday) { date in
                    print("The selected date is \(date ?? Date())")
                }
            },
            .init(title: "Options Representable Picker", subtitle: "Using Picker to select from an options enum") { _, _ in
                Picker.present(selected: ExampleArrowOptions.allCases.first) { option in
                    print("Selected: \(option)")
                }
            },
            .init(title: "Drawer Screen", subtitle: "Dynamic Table View inside Drawer Screen") { _, _ in
                let vc = DynamicTableViewController(style: .plain)
                vc.tableView.sections = [
                    Section(items: [
                        DynamicTableModel(title: "Option 1", subtitle: "FeedViewController demonstration") { _, _ in
                            print("Selected model!!")
                        },
                        DynamicTableModel(title: "Option 2", subtitle: "FeedViewController demonstration"),
                        DynamicTableModel(title: "Option 3", subtitle: "FeedViewController demonstration"),
                        DynamicTableModel(title: "Option 4", subtitle: "FeedViewController demonstration"),
                        DynamicTableModel(title: "Option 5", subtitle: "FeedViewController demonstration")
                    ])
                ]
                vc.view.snp.makeConstraints { make in
                    make.height.equalTo(300)
                }
                DrawerScreen.present(vc.view)
            },
            .init(title: "Picker List: Options Representable", subtitle: "Using Picker to select from an options enum") { _, _ in
                PickerList.present(selected: ExampleArrowOptions.allCases.first) { option in
                    print("Selected: \(option)")
                }
            },
            .init(title: "Picker List: Strings", subtitle: "Using Picker to select from an array of strings") { _, _ in
                PickerList.present(options: [
                    "Option 1",
                    "Option 2",
                    "Option 3",
                    "Option 4",
                    "Option 5"
                ]) { selected in
                    print("Selected: \(selected)")
                }
            },
            .init(title: "Picker List: Timer", subtitle: "Dynamic Table View inside Drawer Screen configured using a view-model") { _, _ in
                let model = ExamplePickerListModel()
                let list = PickerList(model: model).apply {
                    $0.reloadAnimation = .none
                }
                list.present()
            }
        ]
    }
}
