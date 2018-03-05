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
    
    let roomName: String
    var profileImg: UIImage
    
    init(roomName: String, profileImg: UIImage) {
        self.roomName = roomName
        self.profileImg = profileImg
    }
    
    class func addRoom(name: String, roomImg: UIImage, completion: @escaping (Bool) -> Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            let roomID = Database.database().reference().childByAutoId().key.substring(1)
            let key = Database.database().reference().childByAutoId().key.substring(1)
            Database.database().reference().child("users").child(currentUserID).child("contacts").updateChildValues([key:roomID])
            let storageRef = Storage.storage().reference().child("roomImages").child(roomID)
            let imageData = UIImageJPEGRepresentation(roomImg, 0.1)
            storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
                if error == nil {
                    let path = metadata?.downloadURL()?.absoluteString
                    let values = ["name": name, "owner": currentUserID, "roomImgLink": path!]
                    Database.database().reference().child("rooms").child(roomID).child("credentials").updateChildValues(values, withCompletionBlock: { (error, _) in
                        if error == nil {
                            Database.database().reference().child("rooms").child(roomID).child("members").updateChildValues([currentUserID:"true"])
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                } else {
                    completion(false)
                }
            })
        }
    }
    
    class func getRooms(completion: @escaping ([String]) -> Void) {
        if let currentUser = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUser).child("contacts").observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    let receiveRooms = snapshot.value as! [String:String]
                    var rooms: [String] = []
                    for room in receiveRooms {
                        rooms.append(room.value)
                    }
                    completion(rooms)
                }
            })
        }
    }
    
    class func downloadAllRooms(completion: @escaping ([Room]) -> Void) {
        getRooms(completion: { (roomNames) in
            var rooms: [Room] = []
            for roomName in roomNames {
                Database.database().reference().child("rooms").child(roomName).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let value = snapshot.value as! [String:String]
                        let name = value["name"]!
                        let link = URL.init(string: value["roomImgLink"]!)
                        URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                            if error == nil {
                                let roomImg = UIImage.init(data: data!)
                                let room = Room.init(roomName: name, profileImg: roomImg!)
                                rooms.append(room)
                                if roomNames.count == rooms.count {
                                    completion(rooms)
                                }
                            }
                        }).resume()
                    }
                })
            }
        })
    }
    
}
