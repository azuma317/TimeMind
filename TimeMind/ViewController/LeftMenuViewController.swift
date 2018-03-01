//
//  LeftMenuViewController.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/24.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit

class LeftMenuViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var user: User?
    var rooms: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        User.myInfo { [weak self] (user) in
            DispatchQueue.main.async {
                self?.userName.text = user.name
                self?.profileImage.image = user.profileImg
            }
        }
        Room.downloadAllRooms { [weak self] (rooms) in
            DispatchQueue.main.async {
                self?.rooms = rooms
                self?.tableView.reloadData()
            }
        }
    }
    
    @IBAction func addRoom(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddRoomViewController") as! AddRoomViewController
        let nvc: UINavigationController = UINavigationController(rootViewController: vc)
        UINavigationBar.appearance().tintColor = UIColor(hex: "689F38")
        present(nvc, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LeftMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        
        cell.name.text = rooms[indexPath.item].roomName
        cell.roomImage.image = rooms[indexPath.item].profileImg
        
        return cell
    }
    
    
}

extension LeftMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
