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
    
    var owner: String
    var content: String
    var date: String
    private var toID: String?
    private var fromID: String?
    
    init(owner: String, content: String, date: String) {
        self.owner = owner
        self.content = content
        self.date = date
    }
    
    class func downloadAllItems(forUserID: String, completion: @escaping ([Item]) -> Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUserID).child("contacts").child(forUserID).observe(.value, with: { (roomName) in
                if roomName.exists() {
                    let room = roomName.value as! String
                    Database.database().reference().child("items").child(room).observe(.value, with: { (snapshot) in
                        if snapshot.exists() {
                            let receiveItems = snapshot.value as! [String:Any]
                            var items: [Item] = []
                            for item in receiveItems {
                                if item.key != "count" {
                                    let value = item.value as! [String:String]
                                    let content = value["item"]!
                                    let date = value["date"]!
                                    let name = value["owner"]!
                                    let setItem = Item.init(owner: name, content: content, date: date)
                                    items.append(setItem)
                                }
                            }
                            completion(items)
                        }
                    })
                }
            })
        }
    }
    
    class func lastItem(forUserID: String, completion: @escaping (Item) -> Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            let room = Database.database().reference().child("users").child(currentUserID).child("contacts").value(forKey: forUserID) as! String
            Database.database().reference().child("reminders").child(room).observe(.value, with: { (snapshot) in
                let receivedItem = snapshot.value as! NSDictionary
                let lastItem = receivedItem["lastItem"] as! String
                let date = receivedItem["date"] as! String
                let owner = receivedItem["owner"] as! String
                let item = Item.init(owner: owner, content: lastItem, date: date)
                completion(item)
            })
        }
    }
    
    class func send(item: Item, toID: String, completion: @escaping (Bool) -> Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            let value = ["owner":currentUserID, "item":item.content, "date":item.date]
            uploadItem(withItem: value, toID: toID, completion: { (status) in
                
                completion(status)
            })
        }
    }
    
    class func uploadItem(withItem: [String:Any], toID: String, completion: @escaping (Bool) -> Void) {
        if let _ = Auth.auth().currentUser?.uid {
            Room.getRoom(forUserID: toID, completion: { (room) in
                itemCount(room: room, completion: { (count) in
                    Database.database().reference().child("items").child(room).child("i\(count+1)").updateChildValues(withItem)
                    Database.database().reference().child("items").child(room).child("count").setValue("\(count+1)")
                    completion(true)
                })
            })
        } else {
            completion(false)
        }
    }
    
    class func itemCount(room: String, completion: @escaping (Int) -> Void) {
        Database.database().reference().child("items").child(room).child("count").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let countString = snapshot.value as! String
                let count = Int(countString)
                completion(count!)
            }
        })
    }
    
    class func addItemCount(room: String, count: Int) {
        Database.database().reference().child("items").child(room).child("count").setValue(count+1)
    }
    
}
