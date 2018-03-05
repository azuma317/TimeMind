//
//  AddItemViewController.swift
//  TimeMind
//
//  Created by Azuma on 2018/02/28.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UnderLineTextField!
    @IBOutlet weak var dateTextField: UnderLineTextField!
    @IBOutlet var textFields: [UnderLineTextField]!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var roomID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .dateAndTime
        dateTextField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
        if let roomInfo = UserDefaults.standard.dictionary(forKey: "roomInformation") {
            roomID = roomInfo["id"] as! String
        }
    }
    
    @IBAction func dateTextFieldEditingBegin(_ sender: UITextField) {
        let dateFormatter = DateFormatter()
        let now = Date()
        dateFormatter.dateFormat = "MM/dd HH:mm"
        dateTextField.text = dateFormatter.string(from: now)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addLeftBarButtonWithString("Cancel")
        addRightBarButtonWithString("Done")
        nameTextField.becomeFirstResponder()
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func notificationSwitch(_ sender: UISwitch) {
        if sender.isOn {
            dateTextField.alpha = 1
        } else {
            dateTextField.resignFirstResponder()
            dateTextField.alpha = 0
        }
    }
    
    func addLeftBarButtonWithString(_ buttonString: String) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(title: buttonString, style: .plain, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    func addRightBarButtonWithString(_ buttonString: String) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(title: buttonString, style: .plain, target: self, action: #selector(save))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func close() {
        for item in textFields {
            item.resignFirstResponder()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func save() {
        if nameTextField.text != nil {
            let content = nameTextField.text!
            var date = ""
            var notification = "false"
            if notificationSwitch.isOn {
                date = dateTextField.text!
                notification = "true"
            }
            let item: Item = Item.init(content: content, date: date, notification: notification)
            Item.send(item: item, toID: roomID, completion: { [weak weakSelf = self](status) in
                if status {
                    for item in (weakSelf?.textFields)! {
                        item.resignFirstResponder()
                    }
                    weakSelf?.dismiss(animated: true, completion: nil)
                }
            })
        }
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
