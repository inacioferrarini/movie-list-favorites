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

class FavoriteMoviesListViewController: UIViewController, Storyboarded {

    // MARK: - Outlets

    @IBOutlet weak private(set) var favoriteMoviesListView: FavoriteMoviesListView!

    // MARK: - Properties

    weak var appContext: AppContext?
    let searchBarController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadFavorites()
    }

    private func setup() {
        self.title = viewControllerTitle
        self.favoriteMoviesListView.delegate = self
        self.setupSearchField()
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
        let favorites = appContext?.allFavorites()
        let count = favorites?.count ?? 0

        if count == 0 {
            favoriteMoviesListView.showEmptyStateView(message: userDoesNotHaveAnyFavorite)
        } else {
            favoriteMoviesListView.hideEmptyStateView()
        }

        favoriteMoviesListView.favoriteMovies = favorites
    }

}

extension FavoriteMoviesListViewController: Internationalizable {

    var viewControllerTitle: String {
        return string("title", languageCode: "en-US")
    }

    var searchPlaceholder: String {
        return string("searchPlaceholder", languageCode: "en-US")
    }

    var userDoesNotHaveAnyFavorite: String {
        return string("userDoesNotHaveAnyFavorite", languageCode: "en-US")
    }

}

extension FavoriteMoviesListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Searchbar ... text: \(searchText)")
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
        let message = string("movieWasUnfavorited", languageCode: "en-US")
            .replacingOccurrences(of: ":movieName", with: movie.title ?? "")
        self.toast(withSuccessMessage: message)
        self.loadFavorites()
    }

}
