//
//  MessageManager.swift
//  Lighthouse
//
//  Created by Jonathan Tan on 7/3/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import Foundation
import SwiftyJSON

class MessageManager {
    let messagesRef = Firebase(url:"https://beacon-dan.firebaseio.com/messages/")
    let usersRef = Firebase(url:"https://beacon-dan.firebaseio.com/users/")
    
    var firebaseUsers : [[String: String]] = []
    // Reference to current TableViewController
    var currentTableView: ItemsTableViewController?
    var detailView: DetailViewController?
    
    // Instantiate the Singleton
    class var sharedInstance : MessageManager {
        struct Singleton {
            static let instance = MessageManager()
        }
        return Singleton.instance
    }
    
    // ------ Blast(Messaging) Methods -------
    func getUserMessages(){
        // .Value will always be triggered last so the ordering does not matter
        // We just need to cache the messages on load to pass to the Messages View
        
        // This is just used to list the messages the current user has
        messagesRef.childByAppendingPath(sharedAccess.currentUser).observeEventType(.ChildAdded, withBlock: { messages in
            let json = JSON(messages.value)
            var newMessage = Message(json: json)
            
            if (newMessage.type == "Global") {
                Notifications.display(newMessage.title)
                Notifications.alert(newMessage.title, message: newMessage.message, view: self.detailView!)
                self.addMessageSnapshot(newMessage)
            }

            sharedAccess.pingedBackground = false
            sharedAccess.pingedForeground = false
        })
    }
    
    func addMessageSnapshot(newMessage: Message) {
        sharedAccess.myMessages.insert(newMessage, atIndex: 0)
        
        if(currentTableView != nil){
            currentTableView!.insertNewObject()
        }
    }
    
    func getUsersList() {
        usersRef.observeSingleEventOfType(.Value, withBlock: { users -> Void in
            let json = JSON(users.value)
            for (key: String, subJson: JSON) in json {
                self.firebaseUsers.append([subJson["email"].string! : key])
            }
        })
    }
    
    // To modify for pinging absent attendees.
    // Will require a check condition for seeing if attendees are within range of the beacon.
    // May require a data structure to validate against
    func sendMessagesToAttendees(attendees: JSON, room: Room) {
        var recipients : [String] = []
        // Search for attendees in here
        for (index: String, subJson: JSON) in attendees {
            // use email as a key for retrieving the user key to assign messages to
            var searchByEmail = subJson["email"].string!
            for user in self.firebaseUsers {
                // add to recipients only when valid value is found for the key
                if let val = user[searchByEmail] {
                    recipients.append(val)
                }
            }
            println("Recipients: \(recipients)")
        }
        var message = [
            "date" : FirebaseServerValue.timestamp(),
            "location" : room.location,
            "message" : "You are expected at a meeting. Please proceed to \(room.name) immediately!",
            "status" : "Created",
            "title" : "MEETING ALERT",
            "type" : "Global"
        ]
        
        for recipient in recipients {
            messagesRef.childByAppendingPath("\(recipient)").childByAutoId().setValue(message, withCompletionBlock: {
                (error:NSError?, messagesRef) in
                if (error != nil) {
                    println("Message could not be written to user")
                } else {
                    println ("Message sent successfully to \(recipient)")
                }
            })
        }
        Notifications.alert("Ping Attendees", message: "Attendees have been successfully alerted", view: self.detailView!)
    }
}