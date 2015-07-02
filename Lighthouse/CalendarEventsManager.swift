//
//  CalendarEventsManager.swift
//  Lighthouse
//
//  Created by Jonathan Tan on 7/2/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import Foundation
import SwiftyJSON
import GoogleAPIs

class CalendarEventsManager {
    let roomsRef = Firebase(url:"https://beacon-dan.firebaseio.com/rooms/")
    var roomList = [Room]()
    
    // Instantiate the Singleton
    static let sharedInstance = CalendarEventsManager()
    
    // -------- FIREBASE METHODS --------------------------
    func cacheFirebaseData() {
        roomsRef.observeSingleEventOfType(.Value, withBlock: { room in
            let child = room.children
            
            while let r = child.nextObject() as? FDataSnapshot {
                let json = JSON(r)
                // Create new beacon object
                var nRoom = Room(json: json)
                
                // Push room to roomList
                self.roomList.append(nRoom)
            }
            println(self.roomList)
        })
    }
    
    
}