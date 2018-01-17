//
//  LeftMenuView.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/12.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit

class LeftMenuView: SlideMenuView {
    
    override init(position: SlideMenuViewPosition, bounds: CGRect) {
        super.init(position: position, bounds: bounds)
        self.backgroundColor = UIColor.darkGray
//        let tableView = LeftMenuTableView(frame: , style: .plain)
//        self.addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willShow(point: CGPoint) {
        super.willShow(point: point)
        print("Will show")
    }
    
    override func didShow(point: CGPoint) {
        super.didShow(point: point)
        print("Did show")
    }
    
    override func willDisappear(point: CGPoint) {
        super.willDisappear(point: point)
        print("Will disappear")
    }
    
    override func didDisappear(point: CGPoint) {
        super.didDisappear(point: point)
        print("Did disappear")
    }
    
    override func startDragging(point: CGPoint) {
        super.startDragging(point: point)
        print("Start dragging")
    }
    
    override func continueDragging(point: CGPoint) {
        super.continueDragging(point: point)
        print("Continue dragging")
    }
    
    override func endDragging(point: CGPoint) {
        super.endDragging(point: point)
        print("End dragging")
    }
    
}

extension LeftMenuView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LeftMenuTableViewCell
        
        cell.name.text = "sample"
        
        return cell
    }
    
}
