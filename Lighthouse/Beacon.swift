//
//  Beacon.swift
//  Lighthouse
//
//  Created by Roland on 17/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Beacon {
    var name:String!
    var major:UInt16!
    var minor:UInt16!
    var uuid:String!
    
    init (json: JSON) {
        self.major = json["major"].uInt16
        self.minor = json["minor"].uInt16
        self.uuid = json["uuid"].string
    }
}