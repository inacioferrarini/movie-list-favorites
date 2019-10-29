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

public class FavoriteMoviesCoordinator: Coordinator, AppContextAware, LanguageAware {

    // MARK: - Private Properties

    private var tabBar: UITabBarController
    public var appContext: AppContext?
    private var favoriteMovieFilter = FavoriteMovieFilter()

    enum FilterOptionKind: Int {
        case date = 0
        case genre = 1
    }

    // MARK: - Initialization

    public init(tabBar: UITabBarController, appContext: AppContext) {
        self.tabBar = tabBar
        self.appContext = appContext
    }

    // MARK: - Lazy Properties

    lazy var coreDataStack: CoreDataStack = {
        let modelFileName = "FavoriteMovies"
        let databaseFileName = "FavoriteMoviesDB"
        let bundle = Bundle(for: type(of: self))
        return CoreDataStack(modelFileName: modelFileName, databaseFileName: databaseFileName, bundle: bundle)
    }()

    // MARK: - TabBar Management

    lazy var tabBarItem: UITabBarItem? = {
        return UITabBarItem(title: tabBarItemTitle,
                            image: Assets.Icons.Modules.favorite,
                            selectedImage: nil)
    }()

    // MARK: - Coordinated ViewControllers

    public lazy var viewController: UIViewController = {
        guard let vc = favoriteMoviesViewController else { return UIViewController() }
        if let tabBarItem = self.tabBarItem {
            vc.tabBarItem = tabBarItem
        }
        return UINavigationController(rootViewController: vc)
    }()

    private lazy var favoriteMoviesViewController: FavoriteMoviesListViewController? = {
        let vc = FavoriteMoviesListViewController.instantiate(from: "Favorites")
        vc?.delegate = self
        vc?.appContext = self.appContext
        return vc
    }()

    private lazy var favoriteFilterMenuViewController: FavoriteFilterMenuViewController? = {
        let vc = FavoriteFilterMenuViewController.instantiate(from: "Favorites")
        vc?.delegate = self
        vc?.appContext = self.appContext
        return vc
    }()

    private lazy var filterOptionsViewController: FilterOptionsViewController? = {
        let vc = FilterOptionsViewController.instantiate(from: "Favorites")
        vc?.delegate = self
        return vc
    }()

    public lazy var modalViewController: UIViewController = {
        guard let vc = favoriteFilterMenuViewController else { return UIViewController() }
        let navigationController = UINavigationController(rootViewController: vc)
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissModal))
        vc.navigationItem.setRightBarButton(dismissButton, animated: true)
        return navigationController
    }()

    // MARK: - Filters

    lazy var filterFavoriteOptionDate = {
        return FilterFavoriteOption(id: FilterOptionKind.date.rawValue,
                                    title: self.filterByDateOptionTitle)
    }()

    lazy var filterFavoriteOptionGenre = {
        return FilterFavoriteOption(id: FilterOptionKind.genre.rawValue,
                                    title: self.filterByGenreOptionTitle)
    }()

    lazy var favoriteMoviesFilterOptions = {
        return [filterFavoriteOptionDate,
                filterFavoriteOptionGenre]
    }()

    // MARK: - Public Methods

    public func start() {
        self.loadFavorites()
        var viewControllers = tabBar.viewControllers ?? []
        viewControllers += [self.viewController]
        tabBar.viewControllers = viewControllers
    }

    public func finish() {
        if let favorites = appContext?.favorites,
            let managedObjectContext = self.coreDataStack.managedObjectContext {
            Favorite.removeAll(in: managedObjectContext)
            for movie in favorites {
                _ = Favorite.favorite(movie: movie, in: managedObjectContext)
            }
        }
        try? self.coreDataStack.saveContext()
    }

    // MARK: - Favorite Management

    private func loadFavorites() {
        var favoriteMovies: [Movie] = []
        if let managedObjectContext = self.coreDataStack.managedObjectContext,
            let favorites = Favorite.all(in: managedObjectContext) {
            favoriteMovies = favorites.compactMap({ return Movie(favorite: $0) })
        }
        appContext?.add(favorites: favoriteMovies)
    }

    // MARK: - Coordinator

    func showMovieFilter() {
        if let nav = self.viewController as? UINavigationController,
            let vc = favoriteFilterMenuViewController,
            let tabBar = nav.tabBarController {
            vc.favoriteMovieFilter = favoriteMovieFilter
            vc.options = self.favoriteMoviesFilterOptions
            tabBar.present(modalViewController, animated: true, completion: nil)
        }
    }

    @objc
    func dismissModal() {
        modalViewController.dismiss(animated: true, completion: nil)
    }

    func showMovieDateFilterOptions() {
        if let nav = self.modalViewController as? UINavigationController,
            let vc = filterOptionsViewController,
            let appContext = self.appContext {
            vc.filterOptionKind = FilterOptionKind.date.rawValue
            let selectedDate = favoriteMovieFilter.year ?? -1
            vc.options = appContext.dateSearchFilters(selectedValue: selectedDate)
            // set title
            nav.pushViewController(vc, animated: true)
        }
    }

    func showMovieGenreFilterOptions() {
        if let nav = self.modalViewController as? UINavigationController,
            let vc = filterOptionsViewController,
            let appContext = self.appContext {
            vc.filterOptionKind = FilterOptionKind.genre.rawValue
            let selectedGenreId = favoriteMovieFilter.genre?.id ?? -1
            vc.options = appContext.genreSearchFilters(selectedValue: selectedGenreId, genres: appContext.genreList)
            // set title
            nav.pushViewController(vc, animated: true)
        }
    }

}

extension FavoriteMoviesCoordinator: Internationalizable {

    var tabBarItemTitle: String {
        return s("tabBarItemTitle")
    }

    var filterByDateOptionTitle: String {
        return s("filterByDateCellTitle")
    }

    var filterByGenreOptionTitle: String {
        return s("filterByGenreCellTitle")
    }

}

extension FavoriteMoviesCoordinator: FavoriteMoviesListViewControllerDelegate {

    func favoriteMoviesListShowFilter(_ favoriteMoviesListViewController: FavoriteMoviesListViewController) {
        showMovieFilter()
    }

    func favoriteMoviesListShowFilterDidRemoveFilter(_ favoriteMoviesListViewController: FavoriteMoviesListViewController) {
        self.favoriteMovieFilter.genre = nil
        self.favoriteMovieFilter.year = nil
        self.favoriteMoviesViewController?.filter = self.favoriteMovieFilter
    }

}

extension FavoriteMoviesCoordinator: FavoriteFilterMenuViewControllerDelegate {

    func favoriteFilterMenuViewController(_ favoriteFilterViewController: FavoriteFilterMenuViewController, didApplied filter: FavoriteMovieFilter) {
        favoriteMoviesViewController?.filter = filter
        self.dismissModal()
    }

    func favoriteFilterMenuViewController(_ favoriteFilterViewController: FavoriteFilterMenuViewController, didSelected option: FilterFavoriteOption) {
        if option.id == FilterOptionKind.date.rawValue {
            showMovieDateFilterOptions()
        } else if option.id == FilterOptionKind.genre.rawValue {
            showMovieGenreFilterOptions()
        }
    }

}

extension FavoriteMoviesCoordinator: FilterOptionsViewControllerDelegate {

    func filterOptionsViewController(_ filterOptionsViewController: FilterOptionsViewController, didSelected option: FilterOption, kind: Int?) {
        guard let appContext = self.appContext else { return }
        if kind == FilterOptionKind.date.rawValue {
            if option.id == favoriteMovieFilter.year {
                favoriteMovieFilter.year = nil
            } else {
                favoriteMovieFilter.year = option.id
            }
        } else if kind == FilterOptionKind.genre.rawValue {
            if option.id == favoriteMovieFilter.genre?.id {
                favoriteMovieFilter.genre = nil
            } else {
                if let genres: GenreListResult = appContext.genreList,
                    let genreId = option.id {
                    favoriteMovieFilter.genre = genres.genre(for: genreId)
                }
            }
        }
        self.favoriteFilterMenuViewController?.favoriteMovieFilter = favoriteMovieFilter
        filterOptionsViewController.navigationController?.popViewController(animated: true)
    }

}
