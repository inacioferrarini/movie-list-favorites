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

protocol FavoriteMoviesListViewControllerDelegate: AnyObject {

    func favoriteMoviesListShowFilter(_ favoriteMoviesListViewController: FavoriteMoviesListViewController)

}

class FavoriteMoviesListViewController: UIViewController, Storyboarded {

    // MARK: - Outlets

    @IBOutlet weak private(set) var favoriteMoviesListView: FavoriteMoviesListView!

    // MARK: - Properties

    weak var appContext: AppContext?
    weak var delegate: FavoriteMoviesListViewControllerDelegate?
    let searchBarController = UISearchController(searchResultsController: nil)
    var filter: FavoriteMovieFilter?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadFavorites()
        self.favoriteMoviesListView.filter = filter
    }

    private func setup() {
        self.title = viewControllerTitle
        self.favoriteMoviesListView.delegate = self
        self.favoriteMoviesListView.appLanguage = appContext?.appLanguage
        self.setupNavigationBar()
        self.setupSearchField()
    }

    private func setupNavigationBar() {
        let showFiltersButton = UIButton(type: .custom)
        showFiltersButton.setImage(Assets.Icons.Actions.filter, for: .normal)
        showFiltersButton.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        let showFiltersButtonItem = UIBarButtonItem(customView: showFiltersButton)
        self.navigationItem.setRightBarButton(showFiltersButtonItem, animated: true)
    }

    private func setupSearchField() {
        self.navigationItem.searchController = searchBarController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchBarController.searchBar.barTintColor = Assets.Colors.NavigationBar.backgroundColor
        self.searchBarController.searchBar.setTextBackground(Assets.Colors.NavigationBar.textBackgroundColor)
        self.searchBarController.searchBar.showsCancelButton = false
        self.searchBarController.searchBar.showsSearchResultsButton = false
        self.searchBarController.searchBar.delegate = self
        self.searchBarController.searchBar.placeholder = searchPlaceholder
    }

    private func loadFavorites() {
        let count = appContext?.favorites.count ?? 0

        if count == 0 {
            favoriteMoviesListView.showEmptyStateView(message: userDoesNotHaveAnyFavorite)
        } else {
            favoriteMoviesListView.hideEmptyStateView()
        }

        favoriteMoviesListView.favoriteMovies = appContext?.favorites
    }

    // MARK: - Actopms

    @objc func showFilters() {
        self.delegate?.favoriteMoviesListShowFilter(self)
    }

}

extension FavoriteMoviesListViewController: Internationalizable {

    var viewControllerTitle: String {
        guard let language = appContext?.appLanguage.rawValue else { return "#INVALID_LANGUAGE#" }
        return string("title", languageCode: language)
    }

    var searchPlaceholder: String {
        guard let language = appContext?.appLanguage.rawValue else { return "#INVALID_LANGUAGE#" }
        return string("searchPlaceholder", languageCode: language)
    }

    var userDoesNotHaveAnyFavorite: String {
        guard let language = appContext?.appLanguage.rawValue else { return "#INVALID_LANGUAGE#" }
        return string("userDoesNotHaveAnyFavorite", languageCode: language)
    }

    var searchWithoutResults: String {
        guard let language = appContext?.appLanguage.rawValue else { return "#INVALID_LANGUAGE#" }
        return string("searchWithoutResults", languageCode: language)
    }

    var movieWasUnfavoritedMessage: String {
        guard let language = appContext?.appLanguage.rawValue else { return "#INVALID_LANGUAGE#" }
        return string("movieWasUnfavorited", languageCode: language)
    }

}

extension FavoriteMoviesListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard let count = appContext?.allFavorites().count, count > 0 else { return }
//        if searchText.count > 0 {
//            let message = searchWithoutResults
//                .replacingOccurrences(of: ":searchExpression", with: searchText)
//            favoriteMoviesListView.showNotFoundView(message: message)
//        } else {
//            favoriteMoviesListView.hideNotFoundView()
//        }
        // print("Searchbar ... text: \(searchText)")
        //
        //        filtered = data.filter({ (text) -> Bool in
        //            let tmp: NSString = text
        //            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
        //            return range.location != NSNotFound
        //        })
        //        if(filtered.count == 0){
        //            searchActive = false;
        //        } else {
        //            searchActive = true;
        //        }
        //        self.tableView.reloadData()
    }

}

extension FavoriteMoviesListViewController: FavoriteMoviesListViewDelegate {

    func favoriteMoviesListView(_ favoriteMoviesListView: FavoriteMoviesListView, unfavorited movie: Movie) {
        appContext?.remove(favorite: movie)
        let message = movieWasUnfavoritedMessage
            .replacingOccurrences(of: ":movieName", with: movie.title ?? "")
        self.toast(withSuccessMessage: message)
        self.loadFavorites()
    }

}
