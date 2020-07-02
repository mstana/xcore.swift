//
// Xcore
// Copyright © 2019 Xcore
// MIT license, see LICENSE file for details
//

import UIKit

extension Picker {
    final class Content: NSObject, DrawerScreen.Content {
        private static let viewableItemsCount = 5

        private let model: PickerModel
        private lazy var toolbar = InputToolbar().apply {
            $0.backgroundColor = .clear
            $0.didTapDone { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.updateSelectedRows()
                strongSelf.model.pickerDidTapDone()
                strongSelf.dismiss()
            }

            $0.didTapCancel { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.model.pickerDidCancel()
                strongSelf.dismiss()
            }
        }

        private lazy var pickerView = UIPickerView().apply {
            $0.delegate = self
            $0.dataSource = self
            $0.showsSelectionIndicator = true
        }

        private lazy var stackView = UIStackView(arrangedSubviews: [
            toolbar,
            pickerView
        ]).apply {
            $0.axis = .vertical
        }

        var drawerContentView: UIView {
            stackView
        }

        init(model: PickerModel) {
            self.model = model
            super.init()
            commonInit()
        }

        private func commonInit() {
            for i in 0..<model.numberOfComponents() {
                let element = model.selectedElement(at: i)
                pickerView.selectRow(element, inComponent: i, animated: false)
            }
        }

        private func updateSelectedRows() {
            // iterates through all the slider's components and getting the most updated value for each component
            for i in 0..<pickerView.numberOfComponents {
                // takes into account potential changes other component's datasources due to the current component's value change
                model.pickerReloadComponents(on: i).forEach {
                    pickerView.reloadComponent($0)
                    // makes sure to preserve any selected value in reloaded components, if any. Otherwise, set to selected to 0 (top)
                    let selectedRow = max(0, pickerView.selectedRow(inComponent: $0))
                    pickerView.selectRow(selectedRow, inComponent: $0, animated: false)
                    model.pickerDidSelectValue(value: selectedRow, at: $0)
                }
                model.pickerDidSelectValue(value: pickerView.selectedRow(inComponent: i), at: i)
            }
        }
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource

extension Picker.Content: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        model.numberOfElements(at: component)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        model.numberOfComponents()
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        Picker.RowView.height
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let rowView: Picker.RowView
        if let view = view as? Picker.RowView {
            rowView = view
        } else {
            rowView = Picker.RowView()
        }
        rowView.configure(model.element(at: component, row: row))
        return rowView
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        model.pickerDidSelectValue(value: row, at: component)

        model.pickerReloadComponents(on: component).forEach {
            pickerView.reloadComponent($0)
            pickerView.selectRow(0, inComponent: $0, animated: true)
            model.pickerDidSelectValue(value: 0, at: $0)
        }
    }
}

// MARK: - API

extension Picker.Content {
    func present() {
        DrawerScreen.present(self)
    }

    func dismiss() {
        DrawerScreen.dismiss()
    }

    func didTapOtherButton(_ callback: @escaping () -> Void) {
        toolbar.didTapOther { [weak self] in
            guard let strongSelf = self else { return }
            callback()
            strongSelf.dismiss()
        }
    }

    /// Reloads all components of the picker view.
    ///
    /// Calling this method causes the picker view to query the delegate for new
    /// data for all components.
    func reloadData() {
        model.pickerReloadAllComponents()

        guard model.numberOfElements(at: 0) > 0 else {
            // Nothing to display. Dismiss the picker view.
            dismiss()
            return
        }

        pickerView.reloadAllComponents()
    }

    func setTitle(_ title: StringRepresentable?) {
        toolbar.title = title
    }
}
