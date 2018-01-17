//
//  Helper.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/12.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit

typealias GetPoint = (_ point: CGPoint) -> ()
typealias GetSlideWithPoint = (_ slideMenu: SlideMenuView, _ point: CGPoint) -> ()

enum SlideMenuViewPosition {
    case Left, Right
}

enum SlideMenuDirection {
    case Left, Right
}
