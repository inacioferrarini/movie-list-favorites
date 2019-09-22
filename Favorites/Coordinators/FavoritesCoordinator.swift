import Common

public class FavoritesCoordinator: Coordinator {
    
    // MARK: - Private Properties
    
    private var tabBar: UITabBarController
    private var appContext: AppContext
    
    // MARK: - Initialization
    
    public init(tabBar: UITabBarController, appContext: AppContext) {
        self.tabBar = tabBar
        self.appContext = appContext
    }
    
    deinit {
        try? self.coreDataStack.saveContext()
    }
    
    // MARK: - Lazy Properties
  
    lazy var coreDataStack: CoreDataStack = {
        let modelFileName = "Favorites"
        let databaseFileName = "FavoritesDB"
        let bundle = Bundle(for: type(of: self))
        return CoreDataStack(modelFileName: modelFileName, databaseFileName: databaseFileName, bundle: bundle)
    }()

    lazy var tabBarItem: UITabBarItem? = {
        return UITabBarItem(title: tabBarItemTitle,
                            image: Assets.Icons.Modules.favorite,
                            selectedImage: nil)
    }()
    
    public lazy var viewController: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.red
        if let tabBarItem = self.tabBarItem {
            vc.tabBarItem = tabBarItem
        }
        vc.title = tabBarItemTitle     // HERE -- Move to ViewController
        return UINavigationController(rootViewController: vc)
    }()
    
    // MARK: - Public Methods
    
    public func start() {
        var viewControllers = tabBar.viewControllers ?? []
        viewControllers += [self.viewController]
        tabBar.viewControllers = viewControllers
    }
    
}

extension FavoritesCoordinator: Internationalizable {
    
    var tabBarItemTitle: String {
        return string("tabBarItemTitle", languageCode: "en-US")
    }
    
}
