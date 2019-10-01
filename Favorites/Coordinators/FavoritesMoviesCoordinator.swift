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

    public lazy var viewController: UIViewController = {
        guard let vc = favoriteMoviesViewController else { return UIViewController() }
        if let tabBarItem = self.tabBarItem {
            vc.tabBarItem = tabBarItem
        }
        return UINavigationController(rootViewController: vc)
    }()

    private lazy var favoriteMoviesViewController: FavoriteMoviesListViewController? = {
        let vc = FavoriteMoviesListViewController.instantiate(from: "Favorites")
//        vc?.delegate = self
        vc?.appContext = self.appContext
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
        if let managedObjectContext = self.coreDataStack.managedObjectContext,
            let favorites = appContext.allFavorites() {
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

}

extension FavoriteMoviesCoordinator: Internationalizable {

    var tabBarItemTitle: String {
        return string("tabBarItemTitle", languageCode: "en-US")
    }

}
