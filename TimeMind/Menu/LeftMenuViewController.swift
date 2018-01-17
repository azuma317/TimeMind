//
//  LeftMenuViewController.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/12.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit

class LeftSlideMenuViewController: UIViewController {
    
    fileprivate var views = [SlideMenuView]()
    fileprivate var direction: SlideMenuDirection = .Left
    fileprivate var pointBeginning = CGPoint(x: 0, y: 0)
    fileprivate var isInAnimation = false
    
    fileprivate var centeredView: SlideMenuView?
    fileprivate var slideMenuViewLeft: SlideMenuView?
    fileprivate var slideMenuViewRight: SlideMenuView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

extension LeftSlideMenuViewController {
    
    func getCenteredView() -> SlideMenuView? {
        return centeredView
    }
    
    func getSlideMenuLeft() -> SlideMenuView? {
        return slideMenuViewLeft
    }
    
    func getSlideMenuRight() -> SlideMenuView? {
        return slideMenuViewRight
    }
    
    func getSlideMenuAll() -> [SlideMenuView] {
        var slideMenus = [SlideMenuView]()
        if let left = slideMenuViewLeft {
            slideMenus.append(left)
        }
        if let right = slideMenuViewRight {
            slideMenus.append(right)
        }
        return slideMenus
    }
    
    func getPresentingSlideWithPoint(slideMenu: SlideMenuView, point: CGPoint){
    }
}

extension LeftSlideMenuViewController {
    
    func setupSlideMenus(views: [SlideMenuView]) {
        if views.count > 0 {
            self.views = views
            setViewsInDefaultPositions()
            setPanGesture()
            setPrecenceCallback()
        }
    }
    
    private func setPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panView(gesture:)))
        view.addGestureRecognizer(panGesture)
    }
    
    private func setPrecenceCallback() {
        for v in views {
            v.showCallback = {
                self.setViewsInDefaultPositions()
                self.moveToCenter(v: v)
            }
            v.hideCallback = {
                self.direction = self.getDirectionFromPosition(position: v.position)
                self.backToOriginalPosition()
            }
            v.getSlideWithPoint = { (slideMenu, point) in
                self.getPresentingSlideWithPoint(slideMenu: slideMenu, point: point)
            }
        }
    }
    
    fileprivate func setViewsInDefaultPositions() {
        centeredView?.removeFromSuperview()
        centeredView = nil
        for v in views {
            v.removeFromSuperview()
            setViewInDefaultPosition(v: v)
        }
    }
    
    fileprivate func setBeginningPoint() {
        if direction == .Left {
            if let v = slideMenuViewRight {
                pointBeginning = v.frame.origin
                v.willShow(point: pointBeginning)
                v.startDragging(point: pointBeginning)
            }
        } else if direction == .Right {
            if let v = slideMenuViewLeft {
                pointBeginning = v.frame.origin
                v.willShow(point: pointBeginning)
                v.startDragging(point: pointBeginning)
            }
        }
    }
    
    private func setViewInDefaultPosition(v: SlideMenuView) {
        if v.position == .Left {
            slideMenuViewLeft = v
            var frm = slideMenuViewLeft!.frame
            frm.origin.x = -frm.size.width
            frm.origin.y = view.frame.size.height / 2 - frm.size.height / 2
            slideMenuViewLeft?.frame = frm
            view.addSubview(slideMenuViewLeft!)
        } else {
            slideMenuViewRight = v
            var frm = slideMenuViewRight!.frame
            frm.origin.x = view.frame.size.width
            frm.origin.y = view.frame.size.height / 2 - frm.size.height / 2
            slideMenuViewRight?.frame = frm
            view.addSubview(slideMenuViewRight!)
        }
    }
}

extension LeftSlideMenuViewController {
    
    @objc func panView(gesture: UIPanGestureRecognizer) {
        if isInAnimation { return }
        
        let location = gesture.translation(in: view)
        
        if gesture.state == .began {
            if let v = centeredView {
                pointBeginning = v.frame.origin
            } else {
                direction = getDirectionFromGesture(gesture: gesture)
                setBeginningPoint()
                setViewsInDefaultPositions()
            }
        } else if gesture.state == .changed {
            if centeredView != nil {
                dragCenteredView(distance: location)
            } else {
                dragView(distance: location)
            }
        } else if gesture.state == .ended {
            if centeredView != nil {
                controllCenteredViewPositioningDependsOnLocation(location: location)
            } else {
                controllPositioningDependsOnLocation(location: location)
            }
        }
    }
    
    private func controllCenteredViewPositioningDependsOnLocation(location: CGPoint) {
        if let v = centeredView {
            if v.position == .Left {
                if pointBeginning.x + location.x > -v.presentingPoint {
                    moveToCenter(v: v)
                } else {
                    backToOriginalPosition()
                }
            } else if v.position == .Right {
                if pointBeginning.x + location.x < v.presentingPoint {
                    moveToCenter(v: v)
                } else {
                    backToOriginalPosition()
                }
            }
        }
    }
    
    private func controllPositioningDependsOnLocation(location: CGPoint) {
        if direction == .Left {
            if let v = slideMenuViewRight {
                if pointBeginning.x + location.x > -v.presentingPoint {
                    moveToCenter(v: v)
                } else {
                    backToOriginalPosition()
                }
                v.endDragging(point: v.frame.origin)
            }
        } else {
            if let v = slideMenuViewLeft {
                if pointBeginning.x + location.x + v.frame.size.width > v.presentingPoint {
                    moveToCenter(v: v)
                } else {
                    backToOriginalPosition()
                }
                v.endDragging(point: v.frame.origin)
            }
        }
    }
    
    private func dragCenteredView(distance: CGPoint) {
        if let v = centeredView {
            if v.position == .Left {
                let x = pointBeginning.x + distance.x
                if x > v.bounceBackPoint {
                    return moveToCenter(v: v)
                }
                var frm = v.frame
                frm.origin.x = x
                v.frame = frm
                v.continueDragging(point: frm.origin)
            } else if v.position == .Right {
                var x = pointBeginning.x + distance.x
                if x < -v.bounceBackPoint {
                    return moveToCenter(v: v)
                }
                var frm = v.frame
                frm.origin.x = x
                if x < view.frame.size.width { x = view.frame.size.width }
                v.frame = frm
                v.continueDragging(point: frm.origin)
            }
        }
    }
    
    private func dragView(distance: CGPoint) {
        if direction == .Left {
            if let v = slideMenuViewRight {
                var frm = v.frame
                frm.origin.x = pointBeginning.x + distance.x
                v.frame = frm
                v.continueDragging(point: frm.origin)
            }
        } else {
            if let v = slideMenuViewLeft {
                var frm = v.frame
                frm.origin.x = pointBeginning.x + distance.x
                v.frame = frm
                v.continueDragging(point: frm.origin)
            }
        }
    }
    
    fileprivate func moveToCenter(v: SlideMenuView) {
        if isInAnimation { return }
        isInAnimation = true
        UIView.animate(withDuration: 0.3, animations: {
            v.center = self.view.center
        }) { (finished) in
            v.centered = true
            v.endDragging(point: self.view.frame.origin)
            v.didShow(point: self.view.frame.origin)
            self.centeredView = v
            self.isInAnimation = false
        }
    }
    
    func backToOriginalPosition() {
        if direction == .Left {
            if let v = slideMenuViewRight {
                var origin = v.frame.origin
                origin.x = view.frame.size.width
                origin.y = view.frame.size.height / 2 - v.frame.size.height / 2
                isInAnimation = true
                v.willDisappear(point: origin)
                UIView.animate(withDuration: 0.3, animations: {
                    v.frame.origin = origin
                }, completion: { (finished) in
                    v.centered = false
                    v.didDisappear(point: origin)
                    self.isInAnimation = false
                    self.setViewsInDefaultPositions()
                })
            }
        } else {
            if let v = slideMenuViewLeft {
                var origin = v.frame.origin
                origin.x = -v.frame.size.width
                origin.y = view.frame.size.height / 2 - v.frame.size.height / 2
                isInAnimation = true
                v.willDisappear(point: origin)
                UIView.animate(withDuration: 0.3, animations: {
                    v.frame.origin = origin
                }, completion: { (finished) in
                    v.centered = false
                    v.didDisappear(point: origin)
                    self.isInAnimation = false
                    self.setViewsInDefaultPositions()
                })
            }
        }
    }
}

extension LeftSlideMenuViewController {
    
    fileprivate func getDirectionFromGesture(gesture: UIPanGestureRecognizer) -> SlideMenuDirection {
        let velocity = gesture.velocity(in: view)
        if velocity.x > 0 {
            return .Right
        } else {
            return .Left
        }
    }
    
    fileprivate func getDirectionFromPosition(position: SlideMenuViewPosition) -> SlideMenuDirection {
        if position == .Left { return .Right }
        return .Left
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
