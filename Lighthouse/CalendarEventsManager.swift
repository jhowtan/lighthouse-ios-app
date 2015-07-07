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
    var requestManager: Alamofire.Manager?
    var roomList : [Room] = []
    var calendars : JSON = nil
    
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
            // Prepare HTTP packet for sending request
            let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://www.googleapis.com/calendar/v3/freeBusy")!)
            mutableURLRequest.HTTPMethod = "POST"
            var error: NSError? = nil
            let options = NSJSONWritingOptions.allZeros
            if let data = NSJSONSerialization.dataWithJSONObject(params, options: options, error: &error) {
                mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.HTTPBody = data
            }
            
            // Do Alamofire requests
            var manager = Manager.sharedInstance
            manager.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Bearer \(sharedAccess.accessToken)"]
            let request = manager.request(mutableURLRequest)
            request.responseJSON { (request, response, json, error) in
                if(error != nil) {
                    println("Error: \(error)")
                }
                else {
                    var json = JSON(json!)
                    self.calendars = json["calendars"]
                    // Look for calendars that are currently occupied
                    for (key: String, subJson: JSON) in self.calendars {
                        var count = subJson["busy"].count
                        // Calendar is currently busy
                        if (count > 0) {
                            // Find the busy room in roomList array to change to occupied
                            var indexOfBusy = find(self.roomList.map({$0.calendarId}), key)
                            self.roomList[indexOfBusy!].status = "occupied"
                            // Get the event of that is currently taking place.
                            self.getCalendarEvent(key)
                        }
                    }
                }
            }
        }
    }

    func getCalendarEvent(calId: String) {
        var now = NSDate()
        var later = now.add("minute", value: 30)!
        
//        var params : [String: AnyObject] = [
//            "timeMin" : now.toISOString(),
//            "timeMax" : later.toISOString(),
//            "alwaysIncludeEmail": true,
//            "orderBy": "startTime",
//            "showDeleted": false,
//            "singleEvents": true
//        ]

        let url = "https://www.googleapis.com/calendar/v3/calendars/\(calId)/events?timeMin=\(now.toISOString())&timeMax=\(later.toISOString())&alwaysIncludeEmail=true&orderBy=startTime&showDeleted=false&singleEvents=true"
        
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        mutableURLRequest.HTTPMethod = "GET"
        mutableURLRequest.HTTPBody = nil
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var manager = Manager.sharedInstance
        manager.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Bearer \(sharedAccess.accessToken)"]
        let request = manager.request(mutableURLRequest)
        
        manager.request(mutableURLRequest).responseJSON {
            (req, resp, json, error) in
            if (error != nil) {
                println("Error: \(error)")
                println(resp)
            }
            else {
                var json = JSON(json!)
                // Current event
                var currentEvent = json["items"][0]
                println(currentEvent)
                var indexOfBusy = find(self.roomList.map({$0.calendarId}), calId)
                self.roomList[indexOfBusy!].event = currentEvent
            }
        }
    }
    
//    func changeRoomState(mutatedRoom : Room) {
//        // .Value will always be triggered last so the ordering does not matter
//        // We just need to cache the messages on load to pass to the Messages View
//        
//        // This is just used to list the messages the current user has
//        roomsRef.observeEventType(.ChildChanged, withBlock: { changedRoom in
//            let json = JSON(changedRoom.value)
//            var key = json["name"].string
//            var cRoom : Room
//            for r in self.roomList {
//                // Find and retrieve changed room in list
//                if (r.name == key) {
//                    cRoom = r
//                }
//            }
//            // Do something with changed room (cRoom)
//
//        })
//    }

    
    func displayRooms(rooms: Room) {
        if(currentTableView != nil){
            currentTableView!.insertNewObject()
        }
    }
    
}