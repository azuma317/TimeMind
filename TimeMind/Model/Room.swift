//
//  Room.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/24.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class Room {
    
    var roomName: String
    var member: User
    
    init(roomName: String, member: User) {
        self.roomName = roomName
        self.member = member
    }
    
    class func addRoom(forUserID: String, completion: @escaping () -> Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            roomCount(completion: { (count) in
                Database.database().reference().child("users").child(currentUserID).child("contacts").updateChildValues([forUserID:"room\(count+1)"])
                
                Database.database().reference().child("rooms").child("count").setValue("\(count+1)")
                completion()
            })
        }
    }
    
    class func roomCount(completion: @escaping (Int) -> Void) {
        Database.database().reference().child("rooms").child("count").observeSingleEvent(of: .value) { (snapshot) in
            let count: Int = Int(snapshot.value as! String)!
            completion(count)
        }
    }
    
    class func getRoom(forUserID: String, completion: @escaping (String) -> Void) {
        if let currentUser = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUser).child("contacts").child(forUserID).observeSingleEvent(of: .value, with: { (snapshot) in
                let room = snapshot.value as! String
                completion(room)
            })
        }
    }
    
}
