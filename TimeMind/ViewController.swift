//
//  ViewController.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/12.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit

class ViewController: LeftSlideMenuViewController {
    
    var slideMenu: LeftMenuView = {
        let menu = LeftMenuView(position: .Left, bounds: .zero)
        return menu
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        slideMenu.frame = view.bounds
        super.setupSlideMenus(views: [slideMenu])
    }

}

extension ViewController {
    @objc func showMenu() {
        slideMenu.show()
    }
}

