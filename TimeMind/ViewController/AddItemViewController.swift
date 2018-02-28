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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addLeftBarButtonWithString("Cancel")
        addRightBarButtonWithString("Done")
        nameTextField.becomeFirstResponder()
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
        for item in textFields {
            item.resignFirstResponder()
        }
        dismiss(animated: true, completion: nil)
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
