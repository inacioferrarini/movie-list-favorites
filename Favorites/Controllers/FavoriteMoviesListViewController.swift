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

    func favoriteMoviesListShowFilterDidRemoveFilter(_ favoriteMoviesListViewController: FavoriteMoviesListViewController)

}

class FavoriteMoviesListViewController: UIViewController, Storyboarded, AppContextAware, LanguageAware {

    // MARK: - Outlets

    @IBOutlet weak private(set) var favoriteMoviesListView: FavoriteMoviesListView!

    // MARK: - Properties

    weak var appContext: AppContext?
    weak var delegate: FavoriteMoviesListViewControllerDelegate?
    let searchController = UISearchController(searchResultsController: nil)
    var filter: FavoriteMovieFilter? {
        didSet {
            applyFilters()
        }
    }

    // MARK: - Search

    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

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
        self.setupNavigationBarItens()
        self.setupSearchController()
        setupNavigationItem()
    }

    private func setupNavigationBarItens() {
        let showFiltersButton = UIButton(type: .custom)
        showFiltersButton.setImage(Assets.Icons.Actions.filter, for: .normal)
        showFiltersButton.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        let showFiltersButtonItem = UIBarButtonItem(customView: showFiltersButton)
        self.navigationItem.setRightBarButton(showFiltersButtonItem, animated: true)
    }

    private func setupSearchController() {
        self.searchController.searchBar.barTintColor = Assets.Colors.NavigationBar.backgroundColor
        self.searchController.searchBar.setTextBackground(Assets.Colors.NavigationBar.textBackgroundColor)
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = searchPlaceholder
        self.definesPresentationContext = true
    }

    private func setupNavigationItem() {
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = searchController
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

    // MARK: - Actions

    @objc func showFilters() {
        self.delegate?.favoriteMoviesListShowFilter(self)
    }

    // MARK: - Filters

    func applyFilters() {
        guard self.favoriteMoviesListView != nil else { return }
        var predicates: [NSPredicate] = []

        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            let predicate = NSPredicate { (evaluatedObject, _) -> Bool in
                guard let movie = evaluatedObject as? Movie else { return false }
                return movie.title?.contains(searchText) ?? false
            }
            predicates.append(predicate)
        }

        if let filter = self.filter, let filterGenre = filter.genre, let filterGenreId = filterGenre.id {
            let predicate = NSPredicate { (evaluatedObject, _) -> Bool in
                guard let movie = evaluatedObject as? Movie else { return false }
                guard let movieGenreIds = movie.genreIds else { return false }
                return movieGenreIds.contains(filterGenreId)
            }
            predicates.append(predicate)
        }

        if let filter = self.filter, let filterYear = filter.year {
            let predicate = NSPredicate { (evaluatedObject, _) -> Bool in
                guard let movie = evaluatedObject as? Movie else { return false }
                guard let movieYear = movie.releaseDate?.toDate()?.year else { return false }
                return (movieYear == filterYear)
            }
            predicates.append(predicate)
        }

        if predicates.count > 0 {
            self.favoriteMoviesListView.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        } else {
            self.favoriteMoviesListView.predicate = nil
        }
    }

}

extension FavoriteMoviesListViewController: Internationalizable {

    var viewControllerTitle: String {
        return s("title")
    }

    var searchPlaceholder: String {
        return s("searchPlaceholder")
    }

    var userDoesNotHaveAnyFavorite: String {
        return s("userDoesNotHaveAnyFavorite")
    }

    var searchWithoutResults: String {
        return s("searchWithoutResults")
    }

    var movieWasUnfavoritedMessage: String {
        return s("movieWasUnfavorited")
    }

}

extension FavoriteMoviesListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        applyFilters()
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

    func favoriteMoviesListViewDidRemoveFilter(_ favoriteMoviesListView: FavoriteMoviesListView) {
        self.searchController.searchBar.text = nil
        self.favoriteMoviesListView.predicate = nil
        self.delegate?.favoriteMoviesListShowFilterDidRemoveFilter(self)
    }

}
