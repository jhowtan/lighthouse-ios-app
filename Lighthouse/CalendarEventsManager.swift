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
        roomsRef.observeSingleEventOfType(.Value, withBlock: { allRooms in
            let json = JSON(allRooms.value)
            for (key: String, subJson: JSON) in json {
                //Do something you want
                var nRoom = Room(json: subJson)
                nRoom.key = key
                self.roomList.append(nRoom)
            }
        })
        
        // For debugging
        self.getFreeBusy()
    }
    
    // ------ Calendar(Events) Methods -------
    func getFreeBusy() {
        var now = NSDate()
        var later = now.add("minute", value: 30)!
        println("now: \(now.toISOString())")
        println("later: \(later.toISOString())")
        // Need to figure out how to pass the entire array of calendarIds into an
        // array of objects
        let items = [String: String]()
//        for calendar in roomList {
//            items["id"] = calendar.calendarId
//        }
        let params = [
            "timeMin" : now.toISOString(),
            "timeMax" : later.toISOString(),
            "items" : items ]
        let serviceName = "Calendar"
        let apiVersion = "3.0"
        let endpoint = "freeBusy"
   
        // Figure out how to make the processRequest() call with GoogleAPISwiftClient
        let accessToken = SharedAccess.sharedInstance.auth!.token
        println(accessToken)
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
            // Do something with changed room (cRoom)

        })
    }
    
    func displayRooms(rooms: Room) {
        if(currentTableView != nil){
            currentTableView!.insertNewObject()
        }
    }
    
}