//
//  OpponentUser.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/24.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class OpponentUser: NSObject {
    
    let id: String
    let name: String
    let room: String
    let profileImg: UIImage
    
    init(id: String, room: String, name: String, profileImg: UIImage) {
        self.id = id
        self.room = room
        self.name = name
        self.profileImg = profileImg
    }
    
    class func contactUsers(completion: @escaping ([OpponentUser]) -> Void) {
        if let currentUser = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUser).child("contacts").observeSingleEvent(of: .value, with: { (snapshot) in
                if let datas = snapshot.value as? [String:String] {
                    var opponentUsers: [OpponentUser] = []
                    var ids: [String] = []
                    var rooms: [String] = []
                    for data in datas {
                        ids.append(data.key)
                        rooms.append(data.value)
                    }
                    for i in 0..<rooms.count {
                        User.info(id: ids[i], completion: { (user) in
                            let name = user.name
                            let profileImg = user.profileImg
                            let opponentUser: OpponentUser = OpponentUser.init(id: ids[i], room: rooms[i], name: name, profileImg: profileImg)
                            opponentUsers.append(opponentUser)
                            completion(opponentUsers)
                        })
                    }
                }
            })
        }
    }
    
    class func userVerification(key: String, success: @escaping () -> Void, fail: @escaping () -> Void) {
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let values = snapshot.value as! Dictionary<String, Any>
            for value in values {
                print(key)
                print(value.key)
                if key == value.key {
                    success()
                } else {
                    fail()
                }
            }
        })
    }
}
