//
//  DataManager.swift
//  ProductCategory
//
//  Created by Mac on 30/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import CoreData

/// Decode JSON Data received from API into Custom Swift Objects

struct DataManager {
    static let sharedDataManager = DataManager()
    private init() {}
    
    func decode(apiData data: Data) throws -> ProductList? {
        let jsonDecoder = JSONDecoder.init()
        
        let productList = try jsonDecoder.decode(ProductList.self, from: data)
        return productList
    }
}

struct ProductList: Codable {
    var categories: [Category]?
    var rankings: [Ranking]?
}

struct Category: Codable {
    var id: Int?
    var name: String?
    var products: [Product]?
    var child_categories: [Int]?
}

struct Product: Codable {
    var id: Int?
    var name: String?
    var date_added: String?
    var variants: [Variant]?
    var tax: Tax?
}

struct Variant: Codable {
    var id: Int?
    var color: String?
    var size: Int?
    var price: Int?
}

struct Tax: Codable {
    var name: String?
    var value: Double?
}

struct ChildCategory: Codable {
}

struct Ranking: Codable {
    var ranking: String?
    var products: [ProductRanking]?
}

struct ProductRanking: Codable {
    var id: Int?
    var view_count: Int?
}
