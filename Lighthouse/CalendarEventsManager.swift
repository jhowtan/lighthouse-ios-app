//
//  CalendarEventsManager.swift
//  Lighthouse
//
//  Created by Jonathan Tan on 7/2/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import Foundation
import SwiftDate
import SwiftyJSON
import GoogleAPIs
import Alamofire

class CalendarEventsManager {
    let roomsRef = Firebase(url:"https://beacon-dan.firebaseio.com/rooms/")
    var roomList = [Room]()
    
    // Instantiate the Singleton
    class var sharedInstance : CalendarEventsManager {
        struct Singleton {
            static let instance = CalendarEventsManager()
        }
        return Singleton.instance
    }
    
    // Reference to current TableViewController
    var currentTableView: ItemsTableViewController?

    // -------- FIREBASE METHODS -----------
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
        })
        
        self.getFreeBusy()
    }
    
    // ------ Calendar(Events) Methods -------
    func getFreeBusy() {
        let now = NSDate()
        let later = now.add("minute", value: 30)!
        println("now: \(now)")
        println("later: \(later)")
//        let serviceName = "Calendar"
//        let apiVersion = "3.0"
//        let endpoint = "freeBusy"
//        let params = ["timeMin" : "", "timeMax": "", "items" : [String]() ]
//        
   
    }

    func changeRoomState(mutatedRoom : Room) {
        // .Value will always be triggered last so the ordering does not matter
        // We just need to cache the messages on load to pass to the Messages View
        
        // This is just used to list the messages the current user has
        roomsRef.observeEventType(.ChildChanged, withBlock: { changedRoom in
            let json = JSON(changedRoom.value)
            var key = json["name"].string
            var cRoom : Room
            for r in self.roomList {
                // Find and retrieve changed room in list
                if (r.name == key) {
                    cRoom = r
                }
            }
            // Do something with cRoom

        })
    }
    
    func displayRooms(rooms: Room) {
        if(currentTableView != nil){
            currentTableView!.insertNewObject()
        }
    }
    
}