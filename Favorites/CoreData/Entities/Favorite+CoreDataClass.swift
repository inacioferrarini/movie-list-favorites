import Foundation
import CoreData

@objc(Favorite)
public class Favorite: NSManagedObject {

    public class func removeAll(in context: NSManagedObjectContext) {
        guard let favorites = self.all(in: context) else { return }
        for favorite in favorites {
            context.delete(favorite)
        }
    }

    public class func all(in context: NSManagedObjectContext) -> [Favorite]? {
        return self.allObjects(from: self.fetchRequest(), in: context)
    }

    public class func fetch(by movieId: Int, in context: NSManagedObjectContext) -> Favorite? {
        let request: NSFetchRequest = self.fetchRequest()
        request.predicate = NSPredicate(format: "movieId == %i", movieId)
        return self.lastObject(from: request, in: context)
    }

    public class func favorite(with movieId: Int,
                               in context: NSManagedObjectContext) -> Favorite? {
        let favorite = self.fetch(by: movieId, in: context)
        guard favorite == nil else { return favorite }

        guard let newFavorite = NSEntityDescription.insertNewObject(forEntityName: self.simpleClassName(), into: context) as? Favorite else { return nil }

        newFavorite.movieId = Int32(movieId)

        return newFavorite
    }

}
