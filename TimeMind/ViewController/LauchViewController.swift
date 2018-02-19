//
//  LauchViewController.swift
//  TimeMind
//
//  Created by Azuma on 2018/02/19.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit

class LauchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let userInformation = UserDefaults.standard.dictionary(forKey: "userInformation") {
            let email = userInformation["email"] as! String
            let password = userInformation["password"] as! String
            User.login(withEmail: email, password: password, completion: { [weak weakSelf = self](status) in
                DispatchQueue.main.async {
                    if status {
                        weakSelf?.autoLogin(viewController: .items)
                    } else {
                        weakSelf?.autoLogin(viewController: .welcome)
                    }
                    weakSelf = nil
                }
            })
        } else {
            self.autoLogin(viewController: .welcome)
        }
    }
    
    fileprivate func createMenuView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftMenuViewController
        
        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        UINavigationBar.appearance().tintColor = UIColor(hex: "689F38")
        
        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
        slideMenuController.delegate = mainViewController
        self.present(slideMenuController, animated: true, completion: nil)
    }
    
    func autoLogin(viewController: ViewControllerType) {
        switch viewController {
        case .welcome:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(vc, animated: false, completion: nil)
        case .items:
            createMenuView()
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
