//
//  User.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/24.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class User: NSObject {
    
    let name: String
    let email: String
    let id: String
    var profileImg: UIImage
    
    init(name: String, email:String, id: String, profileImg: UIImage) {
        self.name = name
        self.email = email
        self.id = id
        self.profileImg = profileImg
    }
    
    class func regiserUser(withName: String, email: String, password: String, profileImg: UIImage, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                user?.sendEmailVerification(completion: nil)
                let storageRef = Storage.storage().reference().child("usersProfileImages").child(user!.uid)
                let imageData = UIImageJPEGRepresentation(profileImg, 0.1)
                storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
                    if error == nil {
                        let path = metadata?.downloadURL()?.absoluteString
                        let values = ["name": withName, "email": email, "profileImgLink": path!]
                        Database.database().reference().child("users").child((user?.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
                            if errr == nil {
                                let userInfo = ["email": email, "password": password]
                                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                                completion(true)
                            }
                        })
                    }
                })
            }
            else {
                completion(false)
            }
        })
    }
    
    class func login(withEmail: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: withEmail, password: password) { (user, error) in
            if error == nil {
                let userInfo = ["email": withEmail, "password": password]
                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    class func logout(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "userInfomation")
            completion(true)
        } catch _ {
            completion(false)
        }
    }
    
    class func info(id: String, completion: @escaping (User) -> Void) {
        Database.database().reference().child("users").child(id).child("credentials").observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String:String] {
                let name = data["name"]!
                let email = data["email"]!
                let link = URL.init(string: data["profileImgLink"]!)
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        let profileImg = UIImage.init(data: data!)
                        let user = User.init(name: name, email: email, id: id, profileImg: profileImg!)
                        completion(user)
                    }
                }).resume()
            }
        }
    }
    
    class func myInfo(completion: @escaping (User) -> Void) {
        if let currentUser = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUser).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? [String:String] {
                    let name = data["name"]!
                    let email = data["email"]!
                    let link = URL.init(string: data["profileImgLink"]!)
                    URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                        if error == nil {
                            let profileImg = UIImage.init(data: data!)
                            let user = User.init(name: name, email: email, id: currentUser, profileImg: profileImg!)
                            completion(user)
                        }
                    }).resume()
                }
            })
        }
    }
    
    class func checkUserVerification(completion: @escaping (Bool) -> Void) {
        Auth.auth().currentUser?.reload(completion: { (_) in
            let status = (Auth.auth().currentUser?.isEmailVerified)!
            completion(status)
        })
    }
    
}
