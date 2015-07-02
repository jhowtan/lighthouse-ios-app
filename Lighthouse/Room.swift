//
//  Room.swift
//  Lighthouse
//
//  Created by Jonathan Tan on 7/2/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Room {
    let beacon : String!
    let calendarId : String!
    var event : [JSON]!
    let location : String!
    let name : String!
    var status : String!
    
    init (json: JSON) {
        self.beacon = json["beacon"].string
        self.calendarId = json["calendarId"].string
        self.event = json["event"].array
        self.location = json["location"].string
        self.name = json["name"].string
        self.status = json["status"].string
    }
}