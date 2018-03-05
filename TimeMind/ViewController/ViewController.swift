//
//  ViewController.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/12.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        self.tableView.register(UINib(nibName: "ItemNotificationCell", bundle: nil), forCellReuseIdentifier: "ItemNotificationCell")
        
        if let roomInformation = UserDefaults.standard.dictionary(forKey: "roomInformation") {
            let roomID = roomInformation["id"] as! String
            let roomName = roomInformation["name"] as! String
            self.navigationController?.title = roomName
            Item.downloadAllItems(forID: roomID, completion: { [weak weakSelf = self](allItems) in
                DispatchQueue.main.async {
                    weakSelf?.items = allItems
                    weakSelf?.tableView.reloadData()
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationBarItem()
        addRightBarButtonWithImage(#imageLiteral(resourceName: "add"))
    }
    
    func addRightBarButtonWithImage(_ buttonImage: UIImage) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(addItem))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func addItem() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddItemViewController") as! AddItemViewController
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true, completion: nil)
    }

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if items[indexPath.item].notification == "false" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            cell.title.text = items[indexPath.item].content
            tableView.rowHeight = 60

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemNotificationCell", for: indexPath) as! ItemNotificationCell
            cell.title.text = items[indexPath.item].content
            cell.date.text = items[indexPath.item].date
            tableView.rowHeight = 80
            
            return cell
        }
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tableView.reloadData()
    }
}

extension ViewController: MenuViewControllerDelegate {
    
    func leftWillOpen() {
//        print("WillOpen")
    }
    
    func leftDidOpen() {
//        print("DidOpen")
    }
    
    func leftWillClose() {
//        print("WillClose")
        if let roomInformation = UserDefaults.standard.dictionary(forKey: "roomInformation") {
            let roomID = roomInformation["id"] as! String
            let roomName = roomInformation["name"] as! String
            self.navigationController?.title = roomName
            Item.downloadAllItems(forID: roomID, completion: { (allItems) in
                self.items = allItems
                self.tableView.reloadData()
            })
        }
    }
    
    func leftDidClose() {
//        print("DidClose")
    }
    
    func rightTap() {
    }
}

