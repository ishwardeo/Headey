//
//  Utilities.swift
//  ProductList
//
//  Created by Mac on 01/06/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

struct Utilities {
    static func customPrint(headingString heading: String?, anyValue value: Any?) {
        let finalHeading = heading ?? "Some Data"
        let finalValue = value ?? "nil"

        print("\n\n*********** \(finalHeading) ************\n \(finalValue)")
    }
    
    static func printEachObjectIn(sourceArray array: Array<Any>?) {
        guard let unwrappedArray = array else {
            print("\n\n*********** 0 element in the list ************\n")
            return
        }
        for obj in unwrappedArray {
            customPrint(headingString: "obj.categories", anyValue: (obj as AnyObject).categories as Any?)
            customPrint(headingString: "obj.rankings", anyValue: (obj as AnyObject).rankings as Any?)
            
            var productList = ProductList()
            if let tempCategories = (obj as AnyObject).categories {
                if let categoriesArray = tempCategories?.allObjects  {
                    productList.categories = categoriesArray as? [Category]
                    customPrint(headingString: "productList.categories", anyValue: productList.categories as Any?)
                }
            }
                        
            break
        }
    }
}
