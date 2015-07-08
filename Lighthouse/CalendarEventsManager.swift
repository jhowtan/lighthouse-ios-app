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
    var detailView: DetailViewController?

    // -------- FIREBASE METHODS -----------
    func getCalendars() {
        roomsRef.observeSingleEventOfType(.Value, withBlock: { allRooms in
            let json = JSON(allRooms.value)
            for (key: String, subJson: JSON) in json {
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
    
    // --- getFreeBusy()
    // Called when upon click/loading of calendars from main menu
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
        
        // Request body parameters for making POST request
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
            
            // Set accessToken to Authorization Header for request
            var manager = Manager.sharedInstance
            manager.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Bearer \(sharedAccess.accessToken)"]
            let request = manager.request(mutableURLRequest)
            request.validate(statusCode: 200..<300).responseJSON { (request, response, json, error) in
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
                            // Get the event of that is currently taking place.
                            self.getCalendarEvent(key)
                        }
                    }
                    println("Finished getting all busy calendar events")
                }
            }
        }
    }
    // getCalendarEvent(calId: String)
    // Called upon retrieving a list of freeBusy responses from getFreeBusy()
    // Should there be busy events, calendar will obtain a calendar event object for parsing
    func getCalendarEvent(calId: String) {
        var now = NSDate()
        var later = now.add("minute", value: 30)!
        
        // Parameter object is encoded in URL and does not need to be passed in request body
        let url = "https://www.googleapis.com/calendar/v3/calendars/\(calId)/events?timeMin=\(now.toISOString())&timeMax=\(later.toISOString())&alwaysIncludeEmail=true&orderBy=startTime&showDeleted=false&singleEvents=true"
        
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        mutableURLRequest.HTTPMethod = "GET"
        mutableURLRequest.HTTPBody = nil
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var manager = Manager.sharedInstance
        manager.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Bearer \(sharedAccess.accessToken)"]
        let request = manager.request(mutableURLRequest)
        
        manager.request(mutableURLRequest).validate(statusCode: 200..<300).responseJSON {
            (req, resp, json, error) in
            if (error != nil) {
                println("Error: \(error)")
                println(resp)
            }
            else {
                // SUCCESSFUL RESPONSE
                var json = JSON(json!)
                // Current event
                var currentEvent = json["items"][0]
                // println("currentEvent: \(currentEvent)")
                // Find the busy room in roomList array to change to occupied, add current event to room
                var indexOfBusy = find(self.roomList.map({$0.calendarId}), calId)
                self.roomList[indexOfBusy!].status = "occupied"
                self.roomList[indexOfBusy!].event = currentEvent
            }
        }
    }
    
    func bookAvailableRoom(calendar: Room) {
        var now = NSDate()
        var later = now.add("minute", value: 30)!
        // Parameter object is encoded in URL and does not need to be passed in request body
        var params : [String: AnyObject] = [
            "start" : ["dateTime" : now.toISOString()],
            "end" : ["dateTime" : later.toISOString()],
            "attendees": [["email" : sharedAccess.currentUserEmail], ["email" : calendar.calendarId]],
            "location" : calendar.location,
            "summary" : "This room has been booked!",
            "description" : "This room is presently booked by \(sharedAccess.currentUserName), and will be released in 30 mins.",
            "reminders" : ["useDefault": true],
            "transparency" : "opaque",
            "visibility" : "public"
        ]
        
        if NSJSONSerialization.isValidJSONObject(params) {
            // Prepare HTTP packet for sending request
            let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://www.googleapis.com/calendar/v3/calendars/\(sharedAccess.currentUserEmail)/events?sendNotifications=true")!)
            mutableURLRequest.HTTPMethod = "POST"
            var error: NSError? = nil
            let options = NSJSONWritingOptions.allZeros
            if let data = NSJSONSerialization.dataWithJSONObject(params, options: options, error: &error) {
                mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.HTTPBody = data
            }
            
            // Set accessToken to Authorization Header for request
            var manager = Manager.sharedInstance
            manager.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Bearer \(sharedAccess.accessToken)"]
            let request = manager.request(mutableURLRequest)
            request.validate(statusCode: 200..<300).responseJSON {
                (req, resp, json, error) in
                if (error != nil) {
                    println("Error: \(error)")
                    println(resp)
                }
                else {
                    var json = JSON(json!)
                    var index = find(self.roomList.map({$0.calendarId}), calendar.calendarId)
                    self.roomList[index!].event = json
                    Notifications.alert("Book It", message: "This room has been successfully booked", view: self.detailView!)
                }
            }
        }
    }
    
    func displayRooms(rooms: Room) {
        if(currentTableView != nil){
            currentTableView!.insertNewObject()
        }
    }
    
}