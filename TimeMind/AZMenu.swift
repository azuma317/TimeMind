//
//  AZMenu.swift
//  TimeMind
//
//  Created by Azuma on 2018/01/12.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import Foundation

import UIKit

@objc public protocol AZMenuControllerDelegate {
    @objc optional func leftWillOpen()
    @objc optional func leftDidOpen()
    @objc optional func leftWillClose()
    @objc optional func leftDidClose()
    @objc optional func rightTap()
}

public struct AZMenuOptions {
    public static var leftViewWidth: CGFloat = 270.0
    public static var leftBezelWidth: CGFloat? = 16.0
    public static var contentViewScale: CGFloat = 0.96
    public static var contentViewOpacity: CGFloat = 0.5
    public static var contentViewDrag: Bool = false
    public static var shadowOpacity: CGFloat = 0.0
    public static var shadowRadius: CGFloat = 0.0
    public static var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0)
    public static var panFromBezel: Bool = true
    public static var animationDuration: CGFloat = 0.4
    public static var animationOptions: UIViewAnimationOptions = []
    public static var hideStatusBar: Bool = true
    public static var pointOfNoReturnWidth: CGFloat = 44.0
    public static var simultaneousGestureRecognizers: Bool = true
    public static var opacityViewBackgroundColor: UIColor = .black
    public static var panGesturesEnabled: Bool = true
    public static var tapGesturesEnabled: Bool = true
}

class AZMenuController: UIViewController, UIGestureRecognizerDelegate {
    
    public enum SlideAction {
        case open
        case close
    }
    
    public enum TrackAction {
        case leftTapOpen
        case leftTapClose
        case leftFlickOpen
        case leftFlickClose
    }
    
    struct PanInfo {
        var action: SlideAction
        var shouldBounce: Bool
        var velocity: CGFloat
    }
    
    open weak var delegate: AZMenuControllerDelegate?
    
    open var opacityView = UIView()
    open var mainContainerView = UIView()
    open var leftContainerView = UIView()
    open var mainViewController: UIViewController?
    open var leftViewController: UIViewController?
    open var leftPanGesture: UIPanGestureRecognizer?
    open var leftTapGesture: UITapGestureRecognizer?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(mainViewController: UIViewController, leftMenuViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        leftViewController = leftMenuViewController
        initView()
    }
    
    open override func awakeFromNib() {
        initView()
    }
    
    deinit{}
    
    open func initView() {
        mainContainerView = UIView(frame: view.bounds)
        mainContainerView.backgroundColor = UIColor.clear
        mainContainerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.insertSubview(mainContainerView, at: 0)
        
        var opacityframe: CGRect = view.bounds
        let opacityOffset: CGFloat = 0
        opacityframe.origin.y = opacityframe.origin.y + opacityOffset
        opacityframe.size.height = opacityframe.size.height - opacityOffset
        opacityView = UIView(frame: opacityframe)
        opacityView.backgroundColor = AZMenuOptions.opacityViewBackgroundColor
        opacityView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        opacityView.layer.opacity = 0.0
        view.insertSubview(opacityView, at: 1)
        
        if leftViewController != nil {
            var leftFrame: CGRect = view.bounds
            leftFrame.size.width = AZMenuOptions.leftViewWidth
            leftFrame.origin.x = leftMinOrigin()
            let leftOffset: CGFloat = 0
            leftFrame.origin.y = leftFrame.origin.y + leftOffset
            leftFrame.size.height = leftFrame.size.height - leftOffset
            leftContainerView = UIView(frame: leftFrame)
            leftContainerView.backgroundColor = UIColor.clear
            leftContainerView.autoresizingMask = UIViewAutoresizing.flexibleHeight
            view.insertSubview(leftContainerView, at: 2)
            addLeftGestures()
        }
        
    }
    
    // 画面回転時に呼ばれる
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        leftContainerView.isHidden = true
        
        coordinator.animate(alongsideTransition: nil, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.closeLeftNonAnimation()
            self.leftContainerView.isHidden = false
            
            if self.leftPanGesture != nil && self.leftPanGesture != nil {
                self.removeLeftGestures()
                self.addLeftGestures()
            }
        })
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // 回転の向きの制御
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let mainController = self.mainViewController {
            return mainController.supportedInterfaceOrientations
        }
        return UIInterfaceOrientationMask.all
    }
    
    // 回転していいかの設定
    open override var shouldAutorotate: Bool {
        return mainViewController?.shouldAutorotate ?? false
    }
    
    open override func viewWillLayoutSubviews() {
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        setUpViewController(leftContainerView, targetViewController: leftViewController)
    }
    
    // ステイタスバーの設定
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.mainViewController?.preferredStatusBarStyle ?? .default
    }
    
    open override func tapRight() {
        
        self.delegate?.rightTap?()
        
    }
    
    open override func openLeft() {
        guard let _ = leftViewController else {
            return
        }
        
        self.delegate?.leftWillOpen?()
        
        setOpenWindowLevel()
        
        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
        openLeftWithVelocity(0.0)
        
        track(.leftTapOpen)
    }
    
    open override func closeLeft() {
        guard let _ = leftViewController else {
            return
        }
        
        self.delegate?.leftWillClose?()
        
        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
        closeLeftWithVelocity(0.0)
        setCloseWindowLevel()
    }
    
    open func addLeftGestures() {
        if leftViewController != nil {
            if AZMenuOptions.panGesturesEnabled {
                if leftPanGesture == nil {
                    leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleLeftPanGesture(_:)))
                    leftPanGesture!.delegate = self
                    view.addGestureRecognizer(leftPanGesture!)
                }
            }
            
            if AZMenuOptions.tapGesturesEnabled {
                if leftTapGesture == nil {
                    leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.toggleLeft))
                    leftTapGesture!.delegate = self
                    view.addGestureRecognizer(leftTapGesture!)
                }
            }
        }
    }
    
    open func removeLeftGestures() {
        if leftPanGesture != nil {
            view.removeGestureRecognizer(leftPanGesture!)
            leftPanGesture = nil
        }
        
        if leftTapGesture != nil {
            view.removeGestureRecognizer(leftTapGesture!)
            leftTapGesture = nil
        }
    }
    
    open func isTagetViewController() -> Bool {
        return true
    }
    
    open func track(_ trackAction: TrackAction) {
        
    }
    
    struct LeftPanState {
        static var frameAtStartOfPan: CGRect = CGRect.zero
        static var startPointOfPan: CGPoint = CGPoint.zero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
        static var lastState: UIGestureRecognizerState = .ended
    }
    
    @objc func handleLeftPanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        if !isTagetViewController() {
            return
        }
        
        switch panGesture.state {
        case UIGestureRecognizerState.began:
            if LeftPanState.lastState != .ended &&
                LeftPanState.lastState != .cancelled &&
                LeftPanState.lastState != .failed {
                return
            }
            
            if isLeftHidden() {
                self.delegate?.leftWillOpen?()
            } else {
                self.delegate?.leftWillClose?()
            }
            
            LeftPanState.frameAtStartOfPan = leftContainerView.frame
            LeftPanState.startPointOfPan = panGesture.location(in: view)
            LeftPanState.wasOpenAtStartOfPan = isLeftOpen()
            LeftPanState.wasHiddenAtStartOfPan = isLeftHidden()
            
            leftViewController?.beginAppearanceTransition(LeftPanState.wasHiddenAtStartOfPan, animated: true)
            addShadowToView(leftContainerView)
            setOpenWindowLevel()
            
        case UIGestureRecognizerState.changed:
            if LeftPanState.lastState != .began &&
                LeftPanState.lastState != .changed {
                return
            }
            
            let translation: CGPoint = panGesture.translation(in: panGesture.view!)
            leftContainerView.frame = applyLeftTranslation(translation, toFrame: LeftPanState.frameAtStartOfPan)
            applyLeftOpacity()
            applyLeftContentViewScale()
            
        case UIGestureRecognizerState.ended, UIGestureRecognizerState.cancelled:
            if LeftPanState.lastState != .changed {
                setCloseWindowLevel()
                return
            }
            
            let velocity: CGPoint = panGesture.velocity(in: panGesture.view)
            let panInfo: PanInfo = panLeftResultInfoForVelocity(velocity)
            
            if panInfo.action == .open {
                if !LeftPanState.wasHiddenAtStartOfPan {
                    leftViewController?.beginAppearanceTransition(true, animated: true)
                }
                openLeftWithVelocity(panInfo.velocity)
                
                track(.leftFlickOpen)
            } else {
                if LeftPanState.wasHiddenAtStartOfPan {
                    leftViewController?.beginAppearanceTransition(false, animated: true)
                }
                closeLeftWithVelocity(panInfo.velocity)
                setCloseWindowLevel()
                
                track(.leftFlickClose)
            }
            
        case UIGestureRecognizerState.failed, UIGestureRecognizerState.possible:
            break
        }
        
        LeftPanState.lastState = panGesture.state
    }
    
    open func openLeftWithVelocity(_ velocity: CGFloat) {
        let xOrigin: CGFloat = leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = 0.0
        
        var frame = leftContainerView.frame
        frame.origin.x = finalXOrigin
        
        var duration: TimeInterval = Double(AZMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        addShadowToView(leftContainerView)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: AZMenuOptions.animationOptions, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = Float(AZMenuOptions.contentViewOpacity)
                
                AZMenuOptions.contentViewDrag == true ? (strongSelf.mainContainerView.transform = CGAffineTransform(translationX: AZMenuOptions.leftViewWidth, y: 0)) : (strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: AZMenuOptions.contentViewScale, y: AZMenuOptions.contentViewScale))
            }
        }) { [weak self](Bool) -> Void in
            if let strongSelf = self {
                strongSelf.disableContentInteraction()
                strongSelf.leftViewController?.endAppearanceTransition()
                strongSelf.delegate?.leftDidOpen?()
            }
        }
    }
    
    open func closeLeftWithVelocity(_ velocity: CGFloat) {
        let xOrigin: CGFloat = leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = leftMinOrigin()
        
        var frame: CGRect = leftContainerView.frame
        frame.origin.x = finalXOrigin
        
        var duration: TimeInterval = Double(AZMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: AZMenuOptions.animationOptions, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = 0.0
                strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }) { [weak self](Bool) in
            if let strongSelf = self {
                strongSelf.removeShadow(strongSelf.leftContainerView)
                strongSelf.enableContentInteraction()
                strongSelf.leftViewController?.endAppearanceTransition()
                strongSelf.delegate?.leftDidClose?()
            }
        }
    }
    
    open override func toggleLeft() {
        if isLeftOpen() {
            closeLeft()
            setCloseWindowLevel()
            
            track(.leftTapClose)
        } else {
            openLeft()
        }
    }
    
    open func isLeftOpen() -> Bool {
        return leftViewController != nil && leftContainerView.frame.origin.x == 0.0
    }
    
    open func isLeftHidden() -> Bool {
        return leftContainerView.frame.origin.x <= leftMinOrigin()
    }
    
    open func changeMainViewController(key: String,  close: Bool) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        removeViewController(self.mainViewController)
        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        nvc.edgesForExtendedLayout = UIRectEdge.all
        self.mainViewController = nvc
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        if close {
            closeLeft()
        }
    }
    
    open func changeLeftViewWidth(_ width: CGFloat) {
        
        AZMenuOptions.leftViewWidth = width
        var leftFrame: CGRect = view.bounds
        leftFrame.size.width = width
        leftFrame.origin.x = leftMinOrigin()
        let leftOffset: CGFloat = 0
        leftFrame.origin.y = leftFrame.origin.y + leftOffset
        leftFrame.size.height = leftFrame.size.height - leftOffset
        leftContainerView.frame = leftFrame
    }
    
    open func changeLeftViewController(_ leftViewController: UIViewController, closeLeft:Bool) {
        
        removeViewController(self.leftViewController)
        self.leftViewController = leftViewController
        setUpViewController(leftContainerView, targetViewController: leftViewController)
        if closeLeft {
            self.closeLeft()
        }
    }
    
    fileprivate func leftMinOrigin() -> CGFloat {
        return -AZMenuOptions.leftViewWidth
    }
    
    fileprivate func panLeftResultInfoForVelocity(_ velocity: CGPoint) -> PanInfo {
        let thresholdVelocity: CGFloat = 1000.0
        let pointOfNoReturn: CGFloat = CGFloat(floor(leftMinOrigin())) + AZMenuOptions.pointOfNoReturnWidth
        let leftOrigin: CGFloat = leftContainerView.frame.origin.x
        
        var panInfo: PanInfo = PanInfo(action: .close, shouldBounce: false, velocity: 0.0)
        
        panInfo.action = leftOrigin <= pointOfNoReturn ? .close : .open
        
        if velocity.x >= thresholdVelocity {
            panInfo.action = .open
            panInfo.velocity = velocity.x
        } else if velocity.x <= (-1.0 * thresholdVelocity) {
            panInfo.action = .close
            panInfo.velocity = velocity.x
        }
        
        return panInfo
    }
    
    fileprivate func applyLeftTranslation(_ translation: CGPoint, toFrame: CGRect) -> CGRect {
        var newOrigin: CGFloat = toFrame.origin.x
        newOrigin += translation.x
        
        let minOrigin: CGFloat = leftMinOrigin()
        let maxOrigin: CGFloat = 0.0
        var newFrame: CGRect = toFrame
        
        if newOrigin < minOrigin {
            newOrigin = minOrigin
        } else if newOrigin > maxOrigin {
            newOrigin = maxOrigin
        }
        
        newFrame.origin.x = newOrigin
        return newFrame
    }
    
    fileprivate func getOpenedLeftRatio() -> CGFloat {
        let width: CGFloat = leftContainerView.frame.size.width
        let currentPosition: CGFloat = leftContainerView.frame.origin.x - leftMinOrigin()
        return currentPosition / width
    }
    
    fileprivate func applyLeftOpacity() {
        let openedLeftRatio: CGFloat = getOpenedLeftRatio()
        let opacity: CGFloat = AZMenuOptions.contentViewOpacity * openedLeftRatio
        opacityView.layer.opacity = Float(opacity)
    }
    
    fileprivate func applyLeftContentViewScale() {
        let openedLeftRatio: CGFloat = getOpenedLeftRatio()
        let scale: CGFloat = 1.0 - ((1.0 - AZMenuOptions.contentViewScale) * openedLeftRatio)
        let drag: CGFloat = AZMenuOptions.leftViewWidth + leftContainerView.frame.origin.x
        
        AZMenuOptions.contentViewDrag == true ? (mainContainerView.transform = CGAffineTransform(translationX: drag, y: 0)) : (mainContainerView.transform = CGAffineTransform(scaleX: scale, y: scale))
    }
    
    fileprivate func addShadowToView(_ targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = false
        targetContainerView.layer.shadowOffset = AZMenuOptions.shadowOffset
        targetContainerView.layer.shadowOpacity = Float(AZMenuOptions.shadowOpacity)
        targetContainerView.layer.shadowRadius = AZMenuOptions.shadowRadius
        targetContainerView.layer.shadowPath = UIBezierPath(rect: targetContainerView.bounds).cgPath
    }
    
    fileprivate func removeShadow(_ targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = true
        mainContainerView.layer.opacity = 1.0
    }
    
    fileprivate func removeContentOpacity() {
        opacityView.layer.opacity = 0.0
    }
    
    fileprivate func addContentOpacity() {
        opacityView.layer.opacity = Float(AZMenuOptions.contentViewOpacity)
    }
    
    fileprivate func disableContentInteraction() {
        mainContainerView.isUserInteractionEnabled = false
    }
    
    fileprivate func enableContentInteraction() {
        mainContainerView.isUserInteractionEnabled = true
    }
    
    fileprivate func setOpenWindowLevel() {
        if AZMenuOptions.hideStatusBar {
            DispatchQueue.main.async(execute: {
                if let window = UIApplication.shared.keyWindow {
                    window.windowLevel = UIWindowLevelStatusBar + 1
                }
            })
        }
    }
    
    fileprivate func setCloseWindowLevel() {
        if AZMenuOptions.hideStatusBar {
            DispatchQueue.main.async(execute: {
                if let window = UIApplication.shared.keyWindow {
                    window.windowLevel = UIWindowLevelNormal
                }
            })
        }
    }
    
    fileprivate func setUpViewController(_ targetView: UIView, targetViewController: UIViewController?) {
        if let viewController = targetViewController {
            viewController.view.frame = targetView.bounds
            
            if (!childViewControllers.contains(viewController)) {
                addChildViewController(viewController)
                targetView.addSubview(viewController.view)
                viewController.didMove(toParentViewController: self)
            }
        }
    }
    
    fileprivate func removeViewController(_ viewController: UIViewController?) {
        if let _viewController = viewController {
            _viewController.view.layer.removeAllAnimations()
            _viewController.willMove(toParentViewController: nil)
            _viewController.view.removeFromSuperview()
            _viewController.removeFromParentViewController()
        }
    }
    
    open func closeLeftNonAnimation() {
        setCloseWindowLevel()
        let finalXOrigin: CGFloat = leftMinOrigin()
        var frame: CGRect = leftContainerView.frame
        frame.origin.x = finalXOrigin
        leftContainerView.frame = frame
        opacityView.layer.opacity = 0.0
        mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        removeShadow(leftContainerView)
        enableContentInteraction()
    }
    
    // MARK: UIGestureRecognizerDelegate
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        let point: CGPoint = touch.location(in: view)
        
        if gestureRecognizer == leftPanGesture {
            return slideLeftForGestureRecognizer(gestureRecognizer, point: point)
        } else if gestureRecognizer == leftTapGesture {
            return isLeftOpen() && !isPointContainedWithinLeftRect(point)
        }
        
        return true
    }
    
    // returning true here helps if the main view is fullwidth with a scrollview
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return AZMenuOptions.simultaneousGestureRecognizers
    }
    
    fileprivate func slideLeftForGestureRecognizer( _ gesture: UIGestureRecognizer, point:CGPoint) -> Bool{
        return isLeftOpen() || AZMenuOptions.panFromBezel && isLeftPointContainedWithinBezelRect(point)
    }
    
    fileprivate func isLeftPointContainedWithinBezelRect(_ point: CGPoint) -> Bool{
        if let bezelWidth = AZMenuOptions.leftBezelWidth {
            var leftBezelRect: CGRect = CGRect.zero
            let tuple = view.bounds.divided(atDistance: bezelWidth, from: CGRectEdge.minXEdge)
            leftBezelRect = tuple.slice
            return leftBezelRect.contains(point)
        } else {
            return true
        }
    }
    
    fileprivate func isPointContainedWithinLeftRect(_ point: CGPoint) -> Bool {
        return leftContainerView.frame.contains(point)
    }
    
}

extension UIViewController {
    
    func slideMenuController() -> AZMenuController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is AZMenuController {
                return viewController as? AZMenuController
            }
            viewController = viewController?.parent
        }
        return nil
    }
    
    public func addLeftBarButtonWithImage(_ buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.toggleLeft))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    public func addRightBarButtonWithImage() {
        //        let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.tapRight))
        let rightButton: UIBarButtonItem = UIBarButtonItem(title: "+", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.tapRight))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc public func toggleLeft() {
        slideMenuController()?.toggleLeft()
    }
    
    @objc public func openLeft() {
        slideMenuController()?.openLeft()
    }
    
    @objc public func closeLeft() {
        slideMenuController()?.closeLeft()
    }
    
    @objc public func tapRight() {
        slideMenuController()?.tapRight()
    }
    
    public func addPriorityToMenuGesture(_ targetScrollView: UIScrollView) {
        guard let slideController = slideMenuController(), let recognizers = slideController.view.gestureRecognizers else {
            return
        }
        for recognizer in recognizers where recognizer is UIPanGestureRecognizer {
            targetScrollView.panGestureRecognizer.require(toFail: recognizer)
        }
    }
}

