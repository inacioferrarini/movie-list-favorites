import Foundation
import CoreData

@objc(Favorite)
public class Favorite: NSManagedObject {
    
    public class func fetch(by movieId: Int, in context: NSManagedObjectContext) -> Favorite? {
        let request: NSFetchRequest = NSFetchRequest<Favorite>(entityName: self.simpleClassName())
        request.predicate = NSPredicate(format: "movieId = %@", movieId)
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
