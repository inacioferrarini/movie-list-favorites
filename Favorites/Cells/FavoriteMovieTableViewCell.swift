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
/// Cell used to display a favorite movie
///
class FavoriteMovieTableViewCell: UITableViewCell, Configurable, LanguageAware {

    // MARK: - Outlets

    @IBOutlet weak private(set) var posterImage: UIImageView!
    @IBOutlet weak private(set) var titleLabel: UILabel!
    @IBOutlet weak private(set) var yearLabel: UILabel!
    @IBOutlet weak private(set) var overviewLabel: UILabel!

    // MARK: - Properties

    var appLanguage: Language?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupAccessibility()
    }

    // MARK: - Accessibility

    func setupAccessibility() {
        self.posterImage.isAccessibilityElement = false
        self.titleLabel.isAccessibilityElement = false
        self.yearLabel.isAccessibilityElement = false
        self.overviewLabel.isAccessibilityElement = false
        self.isAccessibilityElement = true
    }

    // MARK: - Setup

    func setup(with value: Movie) {
        if let url = URL(string: "http://image.tmdb.org/t/p/w500//" + (value.posterPath ?? "")) {
            UIImage.download(from: url) { [unowned self] (image, _) in
                self.posterImage.image = image
            }
        }

        titleLabel.text = value.title ?? ""

        if let year = value.releaseDate?.toDate()?.year {
            yearLabel.text = "\(year)"
        } else {
            yearLabel.text = "-"
        }

        overviewLabel.text = value.overview ?? ""

        let contentAccessibilityLabel = self.contentAccessibilityLabel
            .replacingOccurrences(of: ":movieTitle", with: value.title ?? "")
            .replacingOccurrences(of: ":movieYear", with: yearLabel.text ?? "")
            .replacingOccurrences(of: ":overview", with: overviewLabel.text ?? "")
        self.accessibilityLabel = contentAccessibilityLabel
    }

}

extension FavoriteMovieTableViewCell: Internationalizable {

    var contentAccessibilityLabel: String {
        return s("contentAccessibilityLabel")
    }

}
