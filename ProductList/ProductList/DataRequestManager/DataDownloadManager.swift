//
//  DataDownloadManager.swift
//  ProductCategory
//
//  Created by Mac on 30/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

enum Result <T>{
    case Success(ProductList)
    case Error(String)
}

struct DataDownloadManager {
    static let sharedDownloadManager = DataDownloadManager()
    private init() {}

    func getDataFromAPI(urlAsString: String?, completion: @escaping  (Result<[String: AnyObject]>) -> Void) {
        
        guard let unwrappedURLAsString = urlAsString else {
            callCompletionHandlerWith(string: "URL is invalid", completion: completion)
            return
        }
        
        guard let tempURL = urlFrom(string: unwrappedURLAsString) else {
            callCompletionHandlerWith(string: "URL is invalid", completion: completion)
            return
        }
        
       URLSession.shared.dataTask(with: tempURL) { (data, response, error) in
            if let unwrappedError = error {
                self.callCompletionHandlerWith(string: unwrappedError.localizedDescription, completion: completion)
                return
            }
            
            guard let unwrappedResponse = response as? HTTPURLResponse else {
                self.callCompletionHandlerWith(string: "Response Error", completion: completion)
                return
            }
            
            if unwrappedResponse.statusCode == 200 {
                guard let unwrappedData = data else {
                    self.callCompletionHandlerWith(string: "Data Error", completion: completion)
                    return
                }
                
                do {
                    if let productList = try DataManager.sharedDataManager.decode(apiData: unwrappedData) {
                        print("******* productList  ******** \n\n", productList as Any)
                        DispatchQueue.main.async {
                            completion(.Success(productList))
                        }
                        return
                    } else {
                        self.callCompletionHandlerWith(string: "Blank List", completion: completion)
                    }
                } catch let error {
                    self.callCompletionHandlerWith(string: error.localizedDescription, completion: completion)
                }
            } else {
                self.callCompletionHandlerWith(string: "Response Error", completion: completion)
                return
            }
        }.resume()
    }
    
    private func callCompletionHandlerWith(string: String?, completion:  @escaping (Result<[String: AnyObject]>) -> Void) {
        let tempMessage = string ?? GlobalConstants.GENERAL_ERROR
                
        DispatchQueue.main.async {
            completion(.Error(tempMessage))
        }
    }
    
    func urlFrom(string str: String?) -> URL? {
       let tempURL = NSURL(string: "https://stark-spire-93433.herokuapp.com/json")
        return tempURL as URL?
    }
}
