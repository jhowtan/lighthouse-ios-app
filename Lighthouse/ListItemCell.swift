//
//  ListItemCell.swift
//  Lighthouse
//
//  Created by Roland on 17/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

class ListItemCell: UITableViewCell {
    
    @IBOutlet weak var msgTitle: UILabel!
    @IBOutlet weak var msgDate: UILabel!
    @IBOutlet weak var roomAvailability: UILabel!
    
    var msgIndex:Int?
}
