//
//  Favorite+CoreDataProperties.swift
//  Favorites
//
//  Created by José Inácio Athayde Ferrarini on 06/10/19.
//  Copyright © 2019 José Inácio Athayde Ferrarini. All rights reserved.
//
//

import Foundation
import CoreData


extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var movieId: Int32
    @NSManaged public var overview: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var title: String?
    @NSManaged public var year: Int32
    @NSManaged public var genreIds: String?

}
