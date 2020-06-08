//
//  MasterViewModel.swift
//  ProductList
//
//  Created by Mac on 05/06/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

class MasterViewModel {
    
    /// closures for communication with View Controller
    var reloadListClosure = {() -> () in}
    var showErrorMessageClosure = {(message: String) -> () in}
    
    var productList: [Dictionary<String, Any>] = [] {
        /// Reload list
        didSet {
            reloadListClosure()
        }
    }
    
    //MARK: - Core data Related methods
    
    // Download data then Decode into Custom objects and save into Core data
    func downloadDataFromAPIThenSaveToCoreData() {
        DataDownloadManager.sharedDownloadManager.getDataFromAPI(urlAsString: GlobalConstants.SERVER_URL) { [weak self] (result) in
            switch result {
                case .Success(let list):
                    print("received productList: \n\n", list)
                    let formattedList = self?.prepareDataForProductScreen(productList: list)
                    print("formattedList", formattedList)
                    // Save to core data
                    self?.coreDataOnSecondaryQueuePrivateContext(productList: list)
                case .Error(let message):
                    print("Error occurred: \n\n", message)
                    if let rootVC = delegate?.window??.rootViewController {
                        AlertController.showAlertWith(fromVC: rootVC, title: "Error", message: message)
                    }
            }
        }
    }
    
    func coreDataOnSecondaryQueuePrivateContext(productList: ProductList) {
        let concurrentQueue = DispatchQueue.init(label: "CoreDataStack", qos: .background, attributes: .concurrent)
            
        let apiDataAlreadySaved = UserDefaults.standard.bool(forKey: GlobalConstants.IS_API_DATA_SAVED)
        if apiDataAlreadySaved == false {
            concurrentQueue.sync {
                Utilities.customPrint(headingString: "Start -- insertRetrieveVariantsUsingPrivateContext", anyValue: "")
                CoreDataStack.saveProductListToCoreDataOnPrivateQueue(productList: productList)
                Utilities.customPrint(headingString: "End -- insertRetrieveVariantsUsingPrivateContext", anyValue: "")
            }
        }
        
        concurrentQueue.sync {
            let productList = CoreDataStack.readUsingPrivateContext()
            Utilities.printEachObjectIn(sourceArray: productList)
        }
    }

    func prepareDataForProductScreen(productList prodList: ProductList?) -> ProductList? {
        guard let unwrappedList = prodList else {
            return nil
        }
        
        var masterArray = Array<Dictionary<String, Any>>()
        
        if let categories = unwrappedList.categories {
            var masterDict = [String: Any]()
            masterDict["categoryName"] = "Categories"
            
            var allCategoriesArray = Array<Dictionary<String, Any>>()

            for oneCategory in categories {
                var oneCategoryDict = Dictionary<String, Any>()

                if let name = oneCategory.name {
                    oneCategoryDict["header"] = name
                    
                    var allProducts = Array<[String: String]>()
                    if let productsArray = oneCategory.products {
                        var articleDict = Dictionary<String, String>()

                        for oneProductDict in productsArray {
                            if let productName = oneProductDict.name {
                                articleDict["productName"] = productName
                                if let variants = oneProductDict.variants {
                                    var colors = ""
                                    for oneVariant in variants {
                                        if let oneColor = oneVariant.color {
                                            colors = colors + " " + oneColor
                                        }
                                    }
                                    
                                    if colors.isEmpty == false {
                                        articleDict["variants"] = colors
                                    }
                                }
                            }
                            allProducts.append(articleDict)
                        }
                    }
                    oneCategoryDict["products"] = allProducts
                }
                allCategoriesArray.append(oneCategoryDict)
            }
            masterDict["categoryList"] = allCategoriesArray
            masterArray.append(masterDict)
        }
        
        productList = masterArray
        Utilities.customPrint(headingString: "masterArray", anyValue: masterArray)
        
        
        //        if let rankings = unwrappedList.rankings {
//            var sortedRankings = rankings.sorted {(rank1, rank2) -> Bool in
//                if let rank1 = rank1.ranking, let rank2 = rank2.ranking {
//                    if let rank1Int = Int(rank1), let rank2Int = Int(rank2) {
//                        return rank1Int > rank2Int
//                    }
//                }
//            }
//
//            var dict = Dictionary<String, String>()
//
//            for oneRank in categories {
//                if let name = oneCategory.name {
//                    dict["header"] = name
//
//                    var allProducts = Array<[String: String]>()
//                    if let productsArray = oneCategory.products {
//                        var articleDict = Dictionary<String, String>()
//
//                        for oneProductDict in productsArray {
//                            if let productName = oneProductDict.name {
//                                articleDict["productName"] = productName
//                                if let variants = oneProductDict.variants {
//                                    var colors = ""
//                                    for oneVariant in variants {
//                                        if let oneColor = oneVariant.color {
//                                            colors = colors + oneColor
//                                        }
//                                    }
//
//                                    if colors.isEmpty == false {
//                                        articleDict["variants"] = colors
//                                    }
//                                }
//                            }
//                        }
//                        allProducts.append(articleDict)
//                    }
//                }
//            }
//            masterListArray.append(dict)
//        }
        return nil
    }
}
