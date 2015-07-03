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
    var major:Int!
    var minor:Int!
    var uuid:String!
    
    init (json: JSON) {
        self.major = json["major"].int
        self.minor = json["minor"].int
        self.uuid = json["uuid"].string
    }
}