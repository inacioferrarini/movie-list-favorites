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

protocol FilterOptionsViewDelegate: AnyObject {

    func filterOptionsView(_ filterOptionsView: FilterOptionsView, didSelected option: Int, kind: Int?)

}

class FilterOptionsView: XibView {

    // MARK: - Outlets

    @IBOutlet weak private(set) var tableView: UITableView!

    // MARK: - Private Properties

    private var dataProvider = ArrayDataProvider<FilterOption>(section: [])
    private var tableViewDataSource: TableViewArrayDataSource<FilterOptionTableViewCell, FilterOption>?

    // MARK: - Properties

    var filterOptionKind: Int?

    var options: [FilterOption]? {
        didSet {
            if let options = options {
                dataProvider.elements = [options]
                tableViewDataSource?.refresh()
            }
        }
    }

    weak var delegate: FilterOptionsViewDelegate?

    // MARK: - Initialization

    override open func setupView() {
        setup()
        setupTableView()
    }

    private func setup() {
    }

    private func setupTableView() {
        let nib = UINib(nibName: FilterOptionTableViewCell.simpleClassName(), bundle: Bundle(for: type(of: self)))
        tableView.register(nib, forCellReuseIdentifier: FilterOptionTableViewCell.simpleClassName())
        let dataSource = TableViewArrayDataSource<FilterOptionTableViewCell, FilterOption>(for: tableView, with: dataProvider)
        tableView.dataSource = dataSource
        self.tableViewDataSource = dataSource
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

}

extension FilterOptionsView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.filterOptionsView(self, didSelected: indexPath.row, kind: filterOptionKind)
    }

}
