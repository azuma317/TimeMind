//
//  Item.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/24.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class Item {
    
    var owner: String?
    var content: String?
    var date: String?
    var notification: String?
    private var toID: String?
    private var fromID: String?
    
    init(owner: String, content: String, date: String, notification: String) {
        self.owner = owner
        self.content = content
        self.date = date
        self.notification = notification
    }
    
    required init(content: String, date: String, notification: String) {
        if let currentUser = Auth.auth().currentUser?.uid {
            self.owner = currentUser
        }
        self.content = content
        self.date = date
        self.notification = notification
    }
    
    class func downloadAllItems(forID: String, completion: @escaping ([Item]) -> Void) {
        if (Auth.auth().currentUser?.uid) != nil {
            Database.database().reference().child("rooms").child(forID).child("items").observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    let receiveItems  = snapshot.value as! [String:Any]
                    var items: [Item] = []
                    for item in receiveItems {
                        let value = item.value as! [String:String]
                        let content = value["item"]!
                        let date = value["date"] ?? ""
                        let name = value["owner"]!
                        let notification = value["notification"]!
                        let setItem = Item.init(owner: name, content: content, date: date, notification: notification)
                        items.append(setItem)
                    }
                    completion(items)
                }
                })
        }
    }
    
//    class func lastItem(forUserID: String, completion: @escaping (Item) -> Void) {
//        if let currentUserID = Auth.auth().currentUser?.uid {
//            let room = Database.database().reference().child("users").child(currentUserID).child("contacts").value(forKey: forUserID) as! String
//            Database.database().reference().child("reminders").child(room).observe(.value, with: { (snapshot) in
//                let receivedItem = snapshot.value as! NSDictionary
//                let lastItem = receivedItem["lastItem"] as! String
//                let date = receivedItem["date"] as! String
//                let owner = receivedItem["owner"] as! String
//                let item = Item.init(owner: owner, content: lastItem, date: date)
//                completion(item)
//            })
//        }
//    }
    
    class func send(item: Item, toID: String, completion: @escaping (Bool) -> Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            let value = ["owner": currentUserID, "item": item.content, "date": item.date, "notification": item.notification] as! [String:String]
            uploadItem(withItem: value, toID: toID, completion: { (status) in
                completion(status)
            })
        }
    }
    
    class func uploadItem(withItem: [String:Any], toID: String, completion: @escaping (Bool) -> Void) {
        if let _ = Auth.auth().currentUser?.uid {
//            Room.getRoom(forUserID: toID, completion: { (room) in
//                    Database.database().reference().child("items").child(room).childByAutoId().updateChildValues(withItem)
//                    completion(true)
//            })
            Database.database().reference().child("rooms").child(toID).child("items").childByAutoId().updateChildValues(withItem)
            completion(true)
        } else {
            completion(false)
        }
    }
    
//    class func itemCount(room: String, completion: @escaping (Int) -> Void) {
//        Database.database().reference().child("items").child(room).child("count").observeSingleEvent(of: .value, with: { (snapshot) in
//            if snapshot.exists() {
//                let countString = snapshot.value as! String
//                let count = Int(countString)
//                completion(count!)
//            }
//        })
//    }
    
//    class func addItemCount(room: String, count: Int) {
//        Database.database().reference().child("items").child(room).child("count").setValue(count+1)
//    }
    
}
