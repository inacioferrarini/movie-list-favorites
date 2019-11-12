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

protocol FavoriteFilterMenuViewDelegate: AnyObject {

    func favoriteFilterMenuView(_ favoriteFilterMenuView: FavoriteFilterMenuView, didApplied filter: FavoriteMovieFilter)

    func favoriteFilterMenuView(_ favoriteFilterMenuView: FavoriteFilterMenuView, didSelected option: Int)

}

class FavoriteFilterMenuView: XibView, LanguageAware {

    // MARK: - Outlets

    @IBOutlet weak private(set) var tableView: UITableView!
    @IBOutlet weak private(set)var applyFilterButton: UIButton!
    var favoriteMovieFilter: FavoriteMovieFilter?

    // MARK: - Private Properties

    private var dataProvider = ArrayDataProvider<FilterFavoriteOption>(section: [])
    private var tableViewDataSource: TableViewArrayDataSource<FilterFavoriteTableViewCell, FilterFavoriteOption>?

    // MARK: - Properties

    var filterOptions: [FilterFavoriteOption]? {
        didSet {
            if let filterOptions = filterOptions {
                dataProvider.elements = [filterOptions]
                tableViewDataSource?.refresh()
            }
        }
    }

    var appLanguage: Language? {
        didSet {
            setupTitles()
        }
    }

    var appTheme: AppThemeProtocol?

    weak var delegate: FavoriteFilterMenuViewDelegate?

    // MARK: - Initialization

    override open func setupView() {
        setup()
        setupTableView()
    }

    private func setup() {
        applyFilterButton.roundBorder(width: 1, radius: 8)
        self.setupAccessibility()
    }

    private func setupAccessibility() {
        applyFilterButton.accessibilityLabel = self.accessibilityApplyButtonLabel
    }

    private func setupTitles() {
        applyFilterButton.setTitle(applyFilterButtonTitle, for: .normal)
    }

    private func setupTableView() {
        let nib = UINib(nibName: FilterFavoriteTableViewCell.simpleClassName(), bundle: Bundle(for: type(of: self)))
        tableView.register(nib, forCellReuseIdentifier: FilterFavoriteTableViewCell.simpleClassName())
        let dataSource = TableViewArrayDataSource<FilterFavoriteTableViewCell, FilterFavoriteOption>(for: tableView, with: dataProvider)
        dataSource.prepareCellBlock = { [unowned self] (_ cell: FilterFavoriteTableViewCell) in
            cell.appLanguage = self.appLanguage
            cell.appTheme = self.appTheme
        }
        tableView.dataSource = dataSource
        self.tableViewDataSource = dataSource
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    // MARK: - Actions

    @IBAction func applyFilter() {
        guard let filter = self.favoriteMovieFilter else { return }
        self.delegate?.favoriteFilterMenuView(self, didApplied: filter)
    }

}

extension FavoriteFilterMenuView: Internationalizable {

    var applyFilterButtonTitle: String {
        return s("applyFilterButtonTitle")
    }

    var accessibilityApplyButtonLabel: String {
        return s("accessibilityApplyButtonLabel")
    }

}

extension FavoriteFilterMenuView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.favoriteFilterMenuView(self, didSelected: indexPath.row)
    }

}
