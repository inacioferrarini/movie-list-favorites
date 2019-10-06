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

import Foundation
import CoreData
import Common

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

    public class func favorite(movie: Movie,
                               in context: NSManagedObjectContext) -> Favorite? {
        guard let movieId = movie.id else { return nil }
        return self.favorite(movieId: movieId,
                             title: movie.title,
                             year: movie.releaseDate?.toDate()?.year,
                             overview: movie.overview,
                             posterPath: movie.posterPath,
                             genreIds: movie.genreIds,
                             in: context)
    }

    public class func favorite(movieId: Int,
                               title: String?,
                               year: Int?,
                               overview: String?,
                               posterPath: String?,
                               genreIds: [Int]?,
                               in context: NSManagedObjectContext) -> Favorite? {
        let favorite = self.fetch(by: movieId, in: context)
        guard favorite == nil else { return favorite }

        guard let newFavorite = NSEntityDescription.insertNewObject(forEntityName: self.simpleClassName(), into: context) as? Favorite else { return nil }

        newFavorite.movieId = Int32(movieId)
        newFavorite.title = title
        newFavorite.year = Int32(year ?? 0)
        newFavorite.overview = overview
        newFavorite.posterPath = posterPath
        if let genresId = genreIds {
            newFavorite.genreIds = genresId.compactMap({ return String(describing: $0) }).joined(separator: ":")
        } else {
            newFavorite.genreIds = nil
        }
        return newFavorite
    }

}
