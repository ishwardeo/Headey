//
//  CoreDataStack.swift
//  ProductList
//
//  Created by Mac on 31/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack {
    // Prevent creation of any object
    private init() {}
    
    //MARK: - Core data Stack

    static func getContext() -> NSManagedObjectContext {
        return CoreDataStack.persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ProductModel")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    static func saveContext() {
        let context = self.getContext()
        
        if context.hasChanges {
            do {
                try context.save()
                UserDefaults.standard.set(true, forKey: GlobalConstants.IS_API_DATA_SAVED)
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Core data Operations using Private Queue
    
    static func getPrivateContext() -> NSManagedObjectContext {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = CoreDataStack.getContext()
        return privateContext
    }

    static func getProductList() -> Array<ProductList1> {
        let request = NSFetchRequest<ProductList1>(entityName: "ProductList1")
        var allVariants = [ProductList1]()
        
        do {
            let fetched = try CoreDataStack.getContext().fetch(request)
            allVariants = fetched
        } catch {
            let nserror = error as NSError
            print(nserror.localizedDescription)
        }
        return allVariants
    }
        
    //MARK: - Private Context

    static func saveUsingPrivateContext() {
        let context = self.getPrivateContext()
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    static func saveProductListToCoreDataOnPrivateQueue(productList prodList: ProductList?) {
        guard let unwrappedProductList = prodList else {
//            AlertController.showAlertWith(fromVC: , title: "Nil Product Data", message: "No data")
            return
        }
        let context = CoreDataStack.getContext()
        let productListEntity = NSEntityDescription.insertNewObject(forEntityName: "ProductList1", into: context)
        
        // To-many categories Relationship
        if let categories = unwrappedProductList.categories {
            var categoriesSet = Set<NSManagedObject>()

            for oneCategory in categories {
                let oneCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "Category1", into: context)

                if let id = oneCategory.id {
                    oneCategoryEntity.setValue(id, forKey: "id")
                }
                
                if let name = oneCategory.name {
                    oneCategoryEntity.setValue(name, forKey: "name")
                }
                
                if let products = oneCategory.products {
                    var productEntities = Set<NSManagedObject>()

                    for oneProduct in products {
                        let oneProductEntity = NSEntityDescription.insertNewObject(forEntityName: "Product1", into: context)
                        
                        if let id = oneProduct.id {
                            oneProductEntity.setValue(id, forKey: "id")
                        }
                        
                        if let name = oneProduct.name {
                            oneProductEntity.setValue(name, forKey: "name")
                        }

                        if let date_added = oneProduct.date_added {
                            oneProductEntity.setValue(date_added, forKey: "date_added")
                        }

                        // Create set of Varient entities
                        if let variants = oneProduct.variants {
                            var variantEntities = Set<NSManagedObject>()
                            for oneVariant in variants {
                                let oneVariantEntity = NSEntityDescription.insertNewObject(forEntityName: "Variant1", into: context)
                                
                                if let id = oneVariant.id {
                                    oneVariantEntity.setValue(id, forKey: "id")
                                }
                                
                                if let price = oneVariant.price {
                                    oneVariantEntity.setValue(price, forKey: "price")
                                }

                                if let size = oneVariant.size {
                                    oneVariantEntity.setValue(size, forKey: "size")
                                }

                                if let color = oneVariant.color {
                                    oneVariantEntity.setValue(color, forKey: "color")
                                }

                                variantEntities.insert(oneVariantEntity)
                            }
                            if variants.count > 0 {
                                oneProductEntity.setValue(variantEntities, forKey: "variants")
                            }
                        }
                        
                        // Create set of Varient entities
                        if let tax = oneProduct.tax {
                            let taxEntity = NSEntityDescription.insertNewObject(forEntityName: "Tax1", into: context)
                            if let name = tax.name {
                                taxEntity.setValue(name, forKey: "name")
                            }
                            if let value = tax.value {
                                taxEntity.setValue(value, forKey: "value")
                            }
                            
                            oneProductEntity.setValue(taxEntity, forKey: "tax")
                        }
                        productEntities.insert(oneProductEntity)
                    }
                    oneCategoryEntity.setValue(productEntities, forKey: "products")
                }
                //TODO: - To change
                if let _ = oneCategory.child_categories {
                    oneCategoryEntity.setValue("child_categories", forKey: "child_categories")
                }
                categoriesSet.insert(oneCategoryEntity)
            }
            productListEntity.setValue(categoriesSet, forKey: "categories")
        }
        
        if let rankings = unwrappedProductList.rankings {
            var rankingsSet = Set<NSManagedObject>()
            
            for oneRanking in rankings {
                let rankingEntity = NSEntityDescription.insertNewObject(forEntityName: "Ranking1", into: context)
                if let ranking = oneRanking.ranking {
                    rankingEntity.setValue(ranking, forKey: "ranking")
                }
                
                if let products = oneRanking.products {
                    var productRankingSet = Set<NSManagedObject>()
                    
                    for oneProduct in products {
                        let productRankingEntity = NSEntityDescription.insertNewObject(forEntityName: "ProductRanking1", into: context)

                        if let id = oneProduct.id {
                            productRankingEntity.setValue(id, forKey: "id")
                        }
                        if let view_count = oneProduct.view_count {
                            productRankingEntity.setValue(view_count, forKey: "view_count")
                        }
                        productRankingSet.insert(productRankingEntity)
                    }
                    
                    rankingEntity.setValue(productRankingSet, forKey: "products")
                }
                rankingsSet.insert(rankingEntity)
            }
            productListEntity.setValue(rankingsSet, forKey: "rankings")
        }
        CoreDataStack.saveContext()
    }
    
    static func readUsingPrivateContext() -> Array<ProductList1> {
        let request = NSFetchRequest<ProductList1>(entityName: "ProductList1")
        var allVariants = [ProductList1]()
        
        do {
            let fetched = try CoreDataStack.getContext().fetch(request)
            allVariants = fetched
        } catch {
            let nserror = error as NSError
            print(nserror.localizedDescription)
        }
        return allVariants
    }
    
    static func deleteAllVariantsUsingPrivateContext() {
        do {
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductList1")
            let deleteAll = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            try CoreDataStack.getContext().execute(deleteAll)
        } catch {
            let nserror = error as NSError
            print(nserror.localizedDescription)
        }
    }
    
}
