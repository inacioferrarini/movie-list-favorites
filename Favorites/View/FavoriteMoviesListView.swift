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

import UIKit
import Common
import Ness

class FavoriteMoviesListView: UIView {

    // MARK: - Outlets

    @IBOutlet weak private(set) var contentView: UIView!
    @IBOutlet weak private(set) var tableView: UITableView!

    // MARK: - Private Properties

    private var dataProvider = ArrayDataProvider<Movie>(section: [])
    private var tableViewDataSource: TableViewArrayDataSource<FavoriteMovieTableViewCell, Movie>?

    // MARK: - Properties

    var favoriteMovies: [Movie]? {
        didSet {
            if let favoriteMovies = favoriteMovies {
                dataProvider.elements = [favoriteMovies]
                tableViewDataSource?.refresh()
            }
        }
    }

    // MARK: - Initialization

    ///
    /// Initializes the view with using `UIScreen.main.bounds` as frame.
    ///
    public required init() {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }

    ///
    /// Initializes the view with using the given `frame`.
    /// - Parameter frame: Initial view dimensions.
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    ///
    /// Initializes the view with using the given `coder`.
    /// - Parameter aDecoder: NSCoder to be used.
    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let className = String(describing: type(of: self))
        bundle.loadNibNamed(className, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setupTableView()
    }

    private func setupTableView() {
        let nib = UINib(nibName: FavoriteMovieTableViewCell.simpleClassName(), bundle: Bundle(for: type(of: self)))
        tableView.register(nib, forCellReuseIdentifier: FavoriteMovieTableViewCell.simpleClassName())
        let dataSource = TableViewArrayDataSource<FavoriteMovieTableViewCell, Movie>(for: tableView, with: dataProvider)
        tableView.dataSource = dataSource
        self.tableViewDataSource = dataSource
        tableView.delegate = self
    }

}

extension FavoriteMoviesListView: UITableViewDelegate {

}
