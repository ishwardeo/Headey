//
//  OneCell.swift
//  ProductList
//
//  Created by Mac on 06/06/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class OneCell: UITableViewCell {
    @IBOutlet weak var categoryName: UILabel!
    
    //@IBOutlet weak var variants: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupLabels(categoryName catText : String? , variantsTxt variantsStr : String?) {
        categoryName.text = catText
        //variants.text = variantsStr
    }
}
