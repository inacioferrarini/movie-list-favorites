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

import Common
import Flow
import Ness

protocol FavoriteFilterViewControllerDelegate: AnyObject {

    func favoriteFilterViewController(_ favoriteFilterViewController: FavoriteFilterViewController, didSelect filter: FavoriteMovieFilter)

}

class FavoriteFilterViewController: UIViewController, Storyboarded {

    // MARK: - Outlets

    @IBOutlet weak private(set) var favoriteFilterView: FavoriteFilterView!

    // MARK: - Properties

    weak var appContext: AppContext?
    weak var delegate: FavoriteFilterViewControllerDelegate?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    private func setup() {
        self.title = viewControllerTitle
        self.favoriteFilterView.delegate = self
        navigationItem.largeTitleDisplayMode = .never
    }

}

extension FavoriteFilterViewController: Internationalizable {

    var viewControllerTitle: String {
        return string("title", languageCode: "en-US")
    }

}

extension FavoriteFilterViewController: FavoriteFilterViewDelegate {

    func favoriteFilterView(_ favoriteFilterView: FavoriteFilterView, didSelected filter: FavoriteMovieFilter) {
        self.delegate?.favoriteFilterViewController(self, didSelect: filter)
    }

}
