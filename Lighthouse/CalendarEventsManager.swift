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
    var roomList : [Room] = []
    
    // Instantiate the Singleton
    class var sharedInstance : CalendarEventsManager {
        struct Singleton {
            static let instance = CalendarEventsManager()
        }
        return Singleton.instance
    }
    
//    class itemIdObject {
//        var calendarId: String
//        
//        init(calendarId: String) {
//            self.calendarId = calendarId
//        }
//    }
//
//    func itemIdObjectToDictionary(itemIdObject) -> [String: String] {
//        return [
//            "id": itemIdObject.calendarId
//        ]
//    }
    
    // Reference to current TableViewController
    var currentTableView: ItemsTableViewController?

    // -------- FIREBASE METHODS -----------
    func cacheFirebaseData() {
        roomsRef.observeEventType(.Value, withBlock: { allRooms in
            let json = JSON(allRooms.value)
            for (key: String, subJson: JSON) in json {
                //Do something you want
                var nRoom = Room(json: subJson)
                nRoom.key = key
                self.roomList.append(nRoom)
            }
            // Show available ones on top
            self.roomList.sort({$0.status < $1.status})
            println("Finish Calendar.cacheFirebaseData")
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
////            var cId = itemIdObject(calendarId: calendar.calendarId)
////            items.append(cId)
//        }
        
        // Need to form params for performing request to Google API
        let params = [
            "timeMin" : now.toISOString(),
            "timeMax" : later.toISOString(),
            "items" : items ]
        let serviceName = "Calendar"
        let apiVersion = "3.0"
        let endpoint = "freeBusy"
   
        // Figure out how to make the processRequest() call with GoogleAPISwiftClient
        let accessToken = SharedAccess.sharedInstance.auth?.token
//        println(accessToken)
        
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
    
//    func _sortByAvailability() {
//        var sorted = [Room]()
//        for r in CalendarEventsManager.sharedInstance.roomList {
//            if (r.status == "available") {
//                sorted.insert(r, atIndex: 0)
//            }
//            else if (r.status == "occupied") {
//                sorted.append(r)
//            }
//        }
//        CalendarEventsManager.sharedInstance.roomList = sorted
//    }
    
    func displayRooms(rooms: Room) {
        if(currentTableView != nil){
            currentTableView!.insertNewObject()
        }
    }
    
}