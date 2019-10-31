//    The MIT License (MIT)
//
//    Copyright (c) 2019 Inácio Ferrarini
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

import UIKit
import Common
import Ness

///
/// Cell used to display a favorite movie filder
///
class FilterFavoriteTableViewCell: UITableViewCell, Configurable, LanguageAware {

    // MARK: - Outlets

    @IBOutlet weak var optionTitleLabel: UILabel!
    @IBOutlet weak var optionValueLabel: UILabel!

    // MARK: - Properties

    var appLanguage: Language?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupAccessibility()
    }

    // MARK: - Accessibility

    func setupAccessibility() {
        self.optionTitleLabel.isAccessibilityElement = false
        self.optionValueLabel.isAccessibilityElement = false
        self.isAccessibilityElement = true
    }

    // MARK: - Setup

    func setup(with value: FilterFavoriteOption) {
        optionTitleLabel.text = value.title ?? ""
        optionValueLabel.text = value.value ?? ""
        accessoryType = .disclosureIndicator
        if let textColor = Assets.Colors.NavigationBar.titleColor {
            self.setDisclosureIndicatorColor(textColor)
        }

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Assets.Colors.NavigationBar.backgroundColor
        self.selectedBackgroundView = selectedBackgroundView

        if value.value != nil {
            self.accessibilityLabel = accessibilityLabelWithValue
                .replacingOccurrences(of: ":paramName", with: value.title ?? "")
                .replacingOccurrences(of: ":paramValue", with: value.value ?? "")
        } else {
            self.accessibilityLabel = accessibilityLabelWithoutValue
                .replacingOccurrences(of: ":paramName", with: value.title ?? "")
        }
    }

}

extension FilterFavoriteTableViewCell: Internationalizable {

    var accessibilityLabelWithValue: String {
        return s("accessibilityLabelWithValue")
    }

    var accessibilityLabelWithoutValue: String {
        return s("accessibilityLabelWithoutValue")
    }

}
