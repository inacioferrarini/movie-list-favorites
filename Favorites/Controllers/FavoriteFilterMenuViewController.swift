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

protocol FavoriteFilterMenuViewControllerDelegate: AnyObject {

    func favoriteFilterMenuViewController(_ favoriteFilterMenuViewController: FavoriteFilterMenuViewController, didApplied filter: FavoriteMovieFilter)

    func favoriteFilterMenuViewController(_ favoriteFilterMenuViewController: FavoriteFilterMenuViewController, didSelected option: FilterFavoriteOption)

}

class FavoriteFilterMenuViewController: UIViewController, Storyboarded, AppContextAware, LanguageAware {

    // MARK: - Outlets

    @IBOutlet weak private(set) var favoriteFilterMenuView: FavoriteFilterMenuView!

    // MARK: - Properties

    weak var appContext: AppContext?
    weak var delegate: FavoriteFilterMenuViewControllerDelegate?
    var options: [FilterFavoriteOption]?
    var favoriteMovieFilter: FavoriteMovieFilter?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    private func setup() {
        self.title = viewControllerTitle
        self.favoriteFilterMenuView.delegate = self
        self.favoriteFilterMenuView.appLanguage = appContext?.appLanguage
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favoriteFilterMenuView.favoriteMovieFilter = favoriteMovieFilter
        self.favoriteFilterMenuView.filterOptions = options
    }

 }

extension FavoriteFilterMenuViewController: Internationalizable {

    var viewControllerTitle: String {
        return s("title")
    }

}

extension FavoriteFilterMenuViewController: FavoriteFilterMenuViewDelegate {

    func favoriteFilterMenuView(_ favoriteFilterMenuView: FavoriteFilterMenuView, didApplied filter: FavoriteMovieFilter) {
        self.delegate?.favoriteFilterMenuViewController(self, didApplied: filter)
    }

    func favoriteFilterMenuView(_ favoriteFilterMenuView: FavoriteFilterMenuView, didSelected option: Int) {
        guard let options = self.options else { return }
        guard option < options.count else { return }
        self.delegate?.favoriteFilterMenuViewController(self, didSelected: options[option])
    }

}
