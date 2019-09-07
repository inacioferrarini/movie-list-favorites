import Common

public class FavoritesCoordinator: Coordinator {
    
    private var tabBar: UITabBarController
    
    public init(tabBar: UITabBarController) {
        self.tabBar = tabBar
    }
    
    public func start() {
        print("starting FavoritesCoordinator ... ")
    }
    
}
