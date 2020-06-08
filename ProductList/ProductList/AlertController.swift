//
//  AlertController.swift
//  ProductCategory
//
//  Created by Mac on 31/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import UIKit

struct AlertController {
    static func showAlertWith(fromVC vc: UIViewController, title: String, message: String, style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: title, style: .default) { (action) in
            vc.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        vc.present(alertController, animated: true, completion: nil)
    }
}
