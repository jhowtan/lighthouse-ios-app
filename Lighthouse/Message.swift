//
//  Message.swift
//  Lighthouse
//
//  Created by Roland on 17/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Message {
    var date:String!
    var location:String!
    var message:String!
    var status:String!
    var title:String!
    var type:String!
    
    init(json: JSON) {
        self.location = json["location"].string
        self.type = json["type"].string
        self.message = json["message"].string
        self.title = json["title"].string
        self.status = json["status"].string
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        if let time = json["date"].double {
            // Cast the value to an NSTimeInterval
            var interval = NSTimeInterval(time)
            // and divide by 1000 to get seconds.
            let date = NSDate(timeIntervalSince1970: interval/1000)
            self.date = dateFormatter.stringFromDate(date)
        }
    }
}
