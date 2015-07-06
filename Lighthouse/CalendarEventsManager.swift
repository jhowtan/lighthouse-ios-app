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
    
    // Reference to current TableViewController
    var currentTableView: ItemsTableViewController?

    // -------- FIREBASE METHODS -----------
    func getCalendars() {
        roomsRef.observeSingleEventOfType(.Value, withBlock: { allRooms in
            let json = JSON(allRooms.value)
            for (key: String, subJson: JSON) in json {
                //Do something you want
                var nRoom = Room(json: subJson)
                nRoom.key = key
                self.roomList.append(nRoom)
            }
            // Show available ones on top
            self.roomList.sort({$0.status < $1.status})
            println("Finish getCalendars")
            self.getFreeBusy()
        })
    }
    
    // ------ Calendar(Events) Methods -------
    
    // -- MARK: for creating JSON objects to pass into data body
    class itemObj {
        var id: String
        init(cid: String) {
            self.id = cid
        }
    }
    
    func itemObjToDict(item: itemObj) -> [String: String] {
        return [
            "id" : item.id
        ]
    }
    
    func getFreeBusy() {
        var now = NSDate()
        var later = now.add("minute", value: 30)!
        println("now: \(now.toISOString())")
        println("later: \(later.toISOString())")

        var items = [[String: String]]()
        for calendar in roomList {
            var item = itemObj(cid: calendar.calendarId)
            var itemDict = itemObjToDict(item)
            items.append(itemDict)
        }
        
        var params : [String: AnyObject] = [
            "timeMin" : now.toISOString(),
            "timeMax" : later.toISOString(),
            "items" : items ]
        
        // Need to form params for performing request to Google API
        if NSJSONSerialization.isValidJSONObject(params) {
            print("params is valid JSON")
            
            // Do your Alamofire requests
            let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://www.googleapis.com/calendar/v3/freeBusy")!)
            mutableURLRequest.HTTPMethod = "POST"
            var error: NSError? = nil
            let options = NSJSONWritingOptions.allZeros
            if let data = NSJSONSerialization.dataWithJSONObject(params, options: options, error: &error) {
                mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.HTTPBody = data
            }
            
            var manager = Manager.sharedInstance
            manager.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Bearer \(sharedAccess.accessToken)"]
            let request = manager.request(mutableURLRequest)
            request.responseJSON { (request, response, JSONData, error) in
                let json = JSON(JSONData!)
                var calendars = json["calendars"]
                println(calendars)
            }
        }

        
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