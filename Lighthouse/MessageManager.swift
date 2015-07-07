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

    // Reference to current TableViewController
    var currentTableView: ItemsTableViewController?
    
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
            
            // Use the appdelegate add message method
            self.addMessageSnapshot(newMessage)
            
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
}