import Foundation
import Common

public class FavoritesModule: Module {
    
    private var tabBar: UITabBarController
    
    public lazy var coordinator: Coordinator = {
        return FavoritesCoordinator(tabBar: self.tabBar)
    }()
    
    public init(tabBar: UITabBarController) {
        self.tabBar = tabBar
    }
    
}
