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
import Ness
import Common

///
/// Adds capabilities to AppContext
///
extension AppContext {

    func uniqueFavoriteDates() -> [Int]? {
        guard let favoriteMovies: FavoriteMoviesType = get(key: FavoriteMoviesKey) else { return nil }
        var dates: Set<Int> = []
        for movie in favoriteMovies {
            if let year = movie.releaseDate?.toDate()?.year {
                dates.insert(year)
            }
        }
        return dates.sorted()
    }

    func uniqueFavoriteGenres() -> [Int]? {
        guard let favoriteMovies: FavoriteMoviesType = get(key: FavoriteMoviesKey) else { return nil }
        var genres: Set<Int> = []
        for movie in favoriteMovies {
            if let genreIds = movie.genreIds {
                genres = genres.union(Set<Int>(genreIds))
            }
        }
        return genres.sorted()
    }

    func dateSearchFilters(selectedValue: Int = -1) -> [FilterOption]? {
        guard let ids = uniqueFavoriteDates() else { return nil }
        return ids.map({ year -> FilterOption in
            let isSelected = (year == selectedValue)
            return FilterOption(title: "\(year)", id: year, isSelected: isSelected)
        })
    }

    func genreSearchFilters(selectedValue: Int = -1, genres: GenreListSearchResultType?) -> [FilterOption]? {
        guard let ids = uniqueFavoriteGenres() else { return nil }
        return ids.map({ genreId -> FilterOption in
            let isSelected = (genreId == selectedValue)
            let genre = genres?.genre(for: genreId)
            return FilterOption(title: genre?.name ?? "", id: genreId, isSelected: isSelected)
        })
    }

}
