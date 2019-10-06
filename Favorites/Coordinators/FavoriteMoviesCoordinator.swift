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

public class FavoriteMoviesCoordinator: Coordinator {

    // MARK: - Private Properties

    private var tabBar: UITabBarController
    private var appContext: AppContext
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

    lazy var tabBarItem: UITabBarItem? = {
        return UITabBarItem(title: tabBarItemTitle,
                            image: Assets.Icons.Modules.favorite,
                            selectedImage: nil)
    }()

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

    private lazy var favoriteFilterViewController: FavoriteFilterViewController? = {
        let vc = FavoriteFilterViewController.instantiate(from: "Favorites")
        vc?.delegate = self
        vc?.appContext = self.appContext
        vc?.options = self.favoriteMoviesFilterOptions
        return vc
    }()

    private lazy var filterOptionsViewController: FilterOptionsViewController? = {
        let vc = FilterOptionsViewController.instantiate(from: "Favorites")
        vc?.delegate = self
        return vc
    }()

    
    
    
    // MARK: - Public Methods

    public func start() {
        self.loadFavorites()
        var viewControllers = tabBar.viewControllers ?? []
        viewControllers += [self.viewController]
        tabBar.viewControllers = viewControllers
    }

    public func finish() {
        if let managedObjectContext = self.coreDataStack.managedObjectContext {
            let favorites = appContext.allFavorites()
            Favorite.removeAll(in: managedObjectContext)
            for movie in favorites {
                _ = Favorite.favorite(movie: movie, in: managedObjectContext)
            }
        }
        try? self.coreDataStack.saveContext()
    }

    private func loadFavorites() {
        var favoriteMovies: FavoriteMoviesType = []
        if let managedObjectContext = self.coreDataStack.managedObjectContext,
            let favorites = Favorite.all(in: managedObjectContext) {
            favoriteMovies = favorites.compactMap({ return Movie(favorite: $0) })
        }
        appContext.add(favorites: favoriteMovies)
    }

    // MARK: - Coordinator

    func showMovieFilter() {
        if let nav = self.viewController as? UINavigationController,
            let vc = favoriteFilterViewController {
            nav.pushViewController(vc, animated: true)
        }
    }

    func showMovieDateFilterOptions() {
let opt1 = FilterOption(title: "Date 0", isChecked: false)
let opt2 = FilterOption(title: "Date 1", isChecked: false)
let opt3 = FilterOption(title: "Date 2", isChecked: false)
let opt4 = FilterOption(title: "Date 3", isChecked: true)
let opt5 = FilterOption(title: "Date 4", isChecked: false)
let options = [opt1, opt2, opt3, opt4, opt5]

        if let nav = self.viewController as? UINavigationController,
            let vc = filterOptionsViewController {
            vc.filterOptionKind = FilterOptionKind.date.rawValue
            vc.options = options
            // set title
            nav.pushViewController(vc, animated: true)
        }
    }

    func showMovieGenreFilterOptions() {
let opt1 = FilterOption(title: "Genre 0", isChecked: false)
let opt2 = FilterOption(title: "Genre 1", isChecked: false)
let opt3 = FilterOption(title: "Genre 2", isChecked: false)
let opt4 = FilterOption(title: "Genre 3", isChecked: false)
let opt5 = FilterOption(title: "Genre 4", isChecked: true)
let options = [opt1, opt2, opt3, opt4, opt5]

        if let nav = self.viewController as? UINavigationController,
            let vc = filterOptionsViewController {
            vc.filterOptionKind = FilterOptionKind.genre.rawValue
            vc.options = options
            // set title
            nav.pushViewController(vc, animated: true)
        }
    }

}

extension FavoriteMoviesCoordinator: Internationalizable {

    var tabBarItemTitle: String {
        return string("tabBarItemTitle", languageCode: "en-US")
    }

    var filterByDateOptionTitle: String {
        return string("filterByDateCellTitle", languageCode: "en-US")
    }

    var filterByGenreOptionTitle: String {
        return string("filterByGenreCellTitle", languageCode: "en-US")
    }

}

extension FavoriteMoviesCoordinator: FavoriteMoviesListViewControllerDelegate {

    func favoriteMoviesListShowFilter(_ favoriteMoviesListViewController: FavoriteMoviesListViewController) {
        showMovieFilter()
    }

}

extension FavoriteMoviesCoordinator: FavoriteFilterViewControllerDelegate {

    func favoriteFilterViewController(_ favoriteFilterViewController: FavoriteFilterViewController, didApplied filter: FavoriteMovieFilter) {
        favoriteMoviesViewController?.filter = filter
        favoriteFilterViewController.navigationController?.popViewController(animated: true)
    }

    func favoriteFilterViewController(_ favoriteFilterViewController: FavoriteFilterViewController, didSelected option: FilterFavoriteOption) {
        if option.id == FilterOptionKind.date.rawValue {
            showMovieDateFilterOptions()
        } else if option.id == FilterOptionKind.genre.rawValue {
            showMovieGenreFilterOptions()
        }
    }

}

extension FavoriteMoviesCoordinator: FilterOptionsViewControllerDelegate {

    func filterOptionsViewController(_ filterOptionsViewController: FilterOptionsViewController, didSelected option: FilterOption, kind: Int?) {
        
        // updates option stored in controller
        // updated options list in view controller
        // updates selected option in favoriteMovieFilter
        
        
        
        
        
        
        
//        let options = filterOptionsViewController.options?.map({ filterOption -> FilterOption in
//            var updatedOption = filterOption
//            updatedOption.isChecked = (option.title == filterOption.title)
//            return updatedOption
//        })
//        filterOptionsViewController.options = options

//        if kind == FilterOptionKind.date.rawValue {
//            favoriteMovieFilter.date = option.title
//        } else if kind == FilterOptionKind.genre.rawValue {
//            favoriteMovieFilter.genre = Genre()  //option.title
//        }

        filterOptionsViewController.navigationController?.popViewController(animated: true)
        print("Final option selected - option: \(option) kind: \(kind)")
    }

}
