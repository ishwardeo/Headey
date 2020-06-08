//
//  HeaderViewCell.swift
//  ProductList
//
//  Created by Mac on 06/06/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class HeaderViewCell:
UITableViewHeaderFooterView {
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupLabels(headerText : String?) {
        headerLabel.text = headerText
    }
}
