//
//  MasterViewController.swift
//  ProductList
//
//  Created by Mac on 31/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

let delegate = UIApplication.shared.delegate

class MasterViewController: UITableViewController {
    
    var viewModel = MasterViewModel()
    
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModelClosures()
        configureViewLayout()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        registerCellXibs()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }
    
    // MARK: - View Model Setup Methods
    
    func setupViewModelClosures() {
        viewModel.reloadListClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.showErrorMessageClosure = { message in
            AlertController.showAlertWith(fromVC: self, title: "Error", message: message)
        }
    }
    
    func configureViewLayout() {
        viewModel.downloadDataFromAPIThenSaveToCoreData()
        tableView.reloadData()
    }
        
    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        let sectionCount = getProductAndVariantForIndex(sectionIndex: 0, rowIndex: 0).0
        return sectionCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rowCount = getProductAndVariantForIndex(sectionIndex: section, rowIndex: 0).1
        return rowCount
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionTitle = getProductAndVariantForIndex(sectionIndex: section, rowIndex: 0).2

        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: HeaderViewCell.self)) as? HeaderViewCell
        headerView?.setupLabels(headerText: sectionTitle)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: OneCell.self), for: indexPath)
        if let cell = cell as? OneCell {
            let cellText = getProductAndVariantForIndex(sectionIndex: indexPath.row, rowIndex: indexPath.section).3
            cell.setupLabels(categoryName: cellText, variantsTxt: nil)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    //MARK: - Table Configuration
    
    func registerCellXibs() {
        tableView.register(UINib.init(nibName: String(describing: OneCell.self), bundle: nil), forCellReuseIdentifier: String(describing: OneCell.self))
       tableView.register(UINib.init(nibName: String(describing: UITableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: UITableViewCell.self))

        tableView.register(UINib.init(nibName: String(describing: HeaderViewCell.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: HeaderViewCell.self))
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView()
    }
    
    //MARK: - Texts
    
    func getHeaderTitle() -> String? {
        var headerTitle: String?
        
        let productList = viewModel.productList
        if productList.count > 0 {
            let categoriesDict = productList[0]
            headerTitle = categoriesDict["categoryName"] as? String
        }
        return headerTitle
    }
    
    func getProductAndVariantForIndex(sectionIndex section: Int, rowIndex row: Int) -> (Int, Int, String, String) {
        var productAndVariant = (0, 0, "", "")
        
        let productList = viewModel.productList
        if productList.count > 0 {
            let categoriesDict = productList[0]
            if let categoryList = categoriesDict["categoryList"] as? Array<Dictionary<String, Any>> {
                if categoryList.count > section {
                    let oneDict = categoryList[section]
                    
                    productAndVariant.0 = categoryList.count // section count
                    
                    let header = oneDict["header"]
                    
                    productAndVariant.2 = header as! String // section Header

                    if let products = oneDict["products"] as? Array<Dictionary<String, String>> {
                        if products.count > row {
                            let oneDict = products[row]
                            
                            productAndVariant.1 = products.count // row count

                            let productName = oneDict["productName"] ?? ""
                            let variants = oneDict["variants"] ?? ""
                            
                            let cellText = productName + "\n" + variants
                            productAndVariant.3 = cellText
                        }
                    }
                }
            }
        }
        return productAndVariant
    }
}

