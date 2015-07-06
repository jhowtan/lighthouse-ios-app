//
//  Beacon.swift
//  Lighthouse
//
//  Created by Roland on 17/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Location {
    var name:String!
    var beacon:String!
    var key:String!
    
    init (json: JSON) {
        self.beacon = json["beacon"].string
        self.name = json["name"].string
    }
}