//
//  SlideMenuView.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/12.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit

// MARK: - init

class SlideMenuView: UIView {
    
    public var showCallback: ()->() = {}
    public var hideCallback: ()->() = {}
    public var getSlideWithPoint: GetSlideWithPoint = {_,_ in}
    public var position: SlideMenuViewPosition = .Left
    public var centered = false
    
    var presentingPoint = 50 as CGFloat
    var bounceBackPoint = 100 as CGFloat
    var keepTrackCurrentPoint: GetPoint = {_ in}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(position: SlideMenuViewPosition, bounds: CGRect) {
        super.init(frame: bounds)
        self.position = position
        backgroundColor = .white
    }
    
    func getPosition() -> SlideMenuViewPosition {
        return position
    }
    
    func willShow(point: CGPoint) {
        keepTrackCurrentPoint(point)
        getSlideWithPoint(self, point)
    }
    
    func didShow(point: CGPoint) {
        keepTrackCurrentPoint(point)
        getSlideWithPoint(self, point)
    }
    
    func willDisappear(point: CGPoint) {
        keepTrackCurrentPoint(point)
        getSlideWithPoint(self, point)
    }
    
    func didDisappear(point: CGPoint) {
        keepTrackCurrentPoint(point)
        getSlideWithPoint(self, point)
    }
    
    func startDragging(point: CGPoint) {
        keepTrackCurrentPoint(point)
        getSlideWithPoint(self, point)
    }
    
    func continueDragging(point: CGPoint) {
        keepTrackCurrentPoint(point)
        getSlideWithPoint(self, point)
    }
    
    func endDragging(point: CGPoint) {
        keepTrackCurrentPoint(point)
        getSlideWithPoint(self, point)
    }

}

// MARK: - Callback

extension SlideMenuView {
    
    func isCentered() -> Bool {
        return centered
    }
    
    func show() {
        showCallback()
    }
    
    func hide() {
        hideCallback()
    }
}
