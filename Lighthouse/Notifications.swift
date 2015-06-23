//
//  Notifications.swift
//  Lighthouse
//
//  Created by Jonathan Tan on 6/23/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import Foundation
import UIKit

class Notifications {
    
    class func display (text: String) {
        let notification: UILocalNotification = UILocalNotification()
        notification.timeZone = NSTimeZone.defaultTimeZone()
        
        let dateTime = NSDate()
        notification.fireDate = dateTime
        notification.alertBody = text
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}