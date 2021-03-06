//
//  REPPASideMenu.swift
//
//  Created by Sebastian Andersen on 06/10/14.
//  Forked from SSASideMenu
//  Alterations to menu animation and configuration as 
//  well as CocoaPod made by Alexander Stonehouse on 13/04/17
//

import Foundation
import UIKit

public extension UIViewController {
    
    public var sideMenuViewController: SideMenu? {
        get {
            return getSideViewController(self)
        }
    }
    
    fileprivate func getSideViewController(_ viewController: UIViewController) -> SideMenu? {
        if let parent = viewController.parent {
            if parent is SideMenu {
                return parent as? SideMenu
            }else {
                return getSideViewController(parent)
            }
        }
        return nil
    }
    
    @IBAction public func presentLeftMenuViewController() {
        
        sideMenuViewController?._presentLeftMenuViewController()
        
    }
    
    @IBAction public func presentRightMenuViewController() {
        
        sideMenuViewController?._presentRightMenuViewController()
    }
}

@objc public protocol SideMenuDelegate {
    
    @objc optional func sideMenuDidRecognizePanGesture(_ sideMenu: SideMenu, recongnizer: UIPanGestureRecognizer)
    @objc optional func sideMenuWillShowMenuViewController(_ sideMenu: SideMenu, menuViewController: UIViewController)
    @objc optional func sideMenuDidShowMenuViewController(_ sideMenu: SideMenu, menuViewController: UIViewController)
    @objc optional func sideMenuWillHideMenuViewController(_ sideMenu: SideMenu, menuViewController: UIViewController)
    @objc optional func sideMenuDidHideMenuViewController(_ sideMenu: SideMenu, menuViewController: UIViewController)
    
}

open class SideMenu: UIViewController, UIGestureRecognizerDelegate {
    
    public enum SideMenuPanDirection {
        case edge
        case everyWhere
        case rect(CGRect)
        case edgeAndRect(CGRect)
    }
    
    public enum SideMenuType: Int {
        case scale = 0
        case slip = 1
    }
    
    public enum StatusBarStyle: Int {
        case hidden = 0
        case black = 1
        case light = 2
    }
    
    fileprivate enum SideMenuSide: Int {
        case left = 0
        case right = 1
    }
    
    public struct ContentViewShadow {
        
        var enabled: Bool = true
        var color: UIColor = UIColor.black
        var offset: CGSize = CGSize.zero
        var opacity: Float = 0.4
        var radius: Float = 8.0
        
        init(enabled: Bool = true, color: UIColor = UIColor.black, offset: CGSize = CGSize.zero, opacity: Float = 0.4, radius: Float = 8.0) {
            
            self.enabled = false
            self.color = color
            self.offset = offset
            self.opacity = opacity
            self.radius = radius
        }
    }
    
    public struct MenuViewEffect {
        
        var fade: Bool = true
        var scale: Bool = true
        var scaleBackground: Bool = true
        var parallaxEnabled: Bool = true
        var bouncesHorizontally: Bool = true
        var statusBarStyle: StatusBarStyle = .black
        
        init(fade: Bool = true, scale: Bool = true, scaleBackground: Bool = true, parallaxEnabled: Bool = true, bouncesHorizontally: Bool = true, statusBarStyle: StatusBarStyle = .black) {
            
            self.fade = fade
            self.scale = scale
            self.scaleBackground = scaleBackground
            self.parallaxEnabled = parallaxEnabled
            self.bouncesHorizontally = bouncesHorizontally
            self.statusBarStyle = statusBarStyle
        }
    }
    
    public struct ContentViewEffect {
        
        var alpha: Float = 1.0
        var scale: Float = 0.7
        var landscapeOffsetX: Float = 30
        var portraitOffsetX: Float = 30
        var minParallaxContentRelativeValue: Float = -25.0
        var maxParallaxContentRelativeValue: Float = 25.0
        var interactivePopGestureRecognizerEnabled: Bool = true
        
        init(alpha: Float = 1.0, scale: Float = 0.7, landscapeOffsetX: Float = 30, portraitOffsetX: Float = 30, minParallaxContentRelativeValue: Float = -25.0, maxParallaxContentRelativeValue: Float = 25.0, interactivePopGestureRecognizerEnabled: Bool = true) {
            
            self.alpha = alpha
            self.scale = scale
            self.landscapeOffsetX = landscapeOffsetX
            self.portraitOffsetX = portraitOffsetX
            self.minParallaxContentRelativeValue = minParallaxContentRelativeValue
            self.maxParallaxContentRelativeValue = maxParallaxContentRelativeValue
            self.interactivePopGestureRecognizerEnabled = interactivePopGestureRecognizerEnabled
        }
    }
    
    public struct SideMenuOptions {
        
        var animationDuration: Float = 0.35
        var panGestureEnabled: Bool = true
        var panDirection: SideMenuPanDirection = .edge
        var type: SideMenuType = .scale
        var panMinimumOpenThreshold: UInt = 60
        var menuViewControllerTransformation: CGAffineTransform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        var backgroundTransformation: CGAffineTransform = CGAffineTransform(scaleX: 1.7, y: 1.7)
        var endAllEditing: Bool = false
        
        init(animationDuration: Float = 0.35, panGestureEnabled: Bool = true, panDirection: SideMenuPanDirection = .edge, type: SideMenuType = .scale, panMinimumOpenThreshold: UInt = 60, menuViewControllerTransformation: CGAffineTransform = CGAffineTransform(scaleX: 1.5, y: 1.5), backgroundTransformation: CGAffineTransform = CGAffineTransform(scaleX: 1.7, y: 1.7), endAllEditing: Bool = false) {
            
            self.animationDuration = animationDuration
            self.panGestureEnabled = panGestureEnabled
            self.panDirection = panDirection
            self.type = type
            self.panMinimumOpenThreshold = panMinimumOpenThreshold
            self.menuViewControllerTransformation = menuViewControllerTransformation
            self.backgroundTransformation = backgroundTransformation
            self.endAllEditing = endAllEditing
        }
    }
    
    open func configure(_ configuration: MenuViewEffect) {
        fadeMenuView = configuration.fade
        scaleMenuView = configuration.scale
        scaleBackgroundImageView = configuration.scaleBackground
        parallaxEnabled = configuration.parallaxEnabled
        bouncesHorizontally = configuration.bouncesHorizontally
    }
    
    open func configure(_ configuration: ContentViewShadow) {
        contentViewShadowEnabled = configuration.enabled
        contentViewShadowColor = configuration.color
        contentViewShadowOffset = configuration.offset
        contentViewShadowOpacity = configuration.opacity
        contentViewShadowRadius = configuration.radius
    }
    
    open func configure(_ configuration: ContentViewEffect) {
        contentViewScaleValue = configuration.scale
        contentViewFadeOutAlpha = configuration.alpha
        contentViewInPortraitOffsetCenterX = configuration.portraitOffsetX
        parallaxContentMinimumRelativeValue = configuration.minParallaxContentRelativeValue
        parallaxContentMaximumRelativeValue = configuration.maxParallaxContentRelativeValue
    }
    
    open func configure(_ configuration: SideMenuOptions) {
        animationDuration = configuration.animationDuration
        panGestureEnabled = configuration.panGestureEnabled
        panDirection = configuration.panDirection
        type = configuration.type
        panMinimumOpenThreshold = configuration.panMinimumOpenThreshold
        menuViewControllerTransformation = configuration.menuViewControllerTransformation
        backgroundTransformation = configuration.backgroundTransformation
        endAllEditing = configuration.endAllEditing
    }
    
    // MARK: Storyboard Support
    @IBInspectable open var contentViewStoryboardID: String?
    @IBInspectable open var leftMenuViewStoryboardID: String?
    @IBInspectable open var rightMenuViewStoryboardID: String?
    
    // MARK: Private Properties: MenuView & BackgroundImageView
    @IBInspectable var fadeMenuView: Bool = true
    @IBInspectable var startMenuAlpha: Float = 0.2
    @IBInspectable var scaleMenuView: Bool = true
    @IBInspectable var scaleBackgroundImageView: Bool = true
    @IBInspectable var parallaxEnabled: Bool = true
    @IBInspectable var bouncesHorizontally: Bool = true
    
    // MARK: Public Properties: MenuView
    @IBInspectable open var statusBarStyle: StatusBarStyle = .black
    
    // MARK: Private Properties: ContentView
    @IBInspectable var contentViewScaleValue: Float = 1.1
    @IBInspectable var contentViewFadeOutAlpha: Float = 1.0
    @IBInspectable var contentViewInPortraitOffsetCenterX: Float = 30.0
    @IBInspectable var contentViewInPortraitOffsetCenterY: Float = 60.0
    @IBInspectable var parallaxContentMinimumRelativeValue: Float = -25.0
    @IBInspectable var parallaxContentMaximumRelativeValue: Float = 25.0
    
    // MARK: Public Properties: ContentView
    @IBInspectable open var interactivePopGestureRecognizerEnabled: Bool = true
    @IBInspectable open var endAllEditing: Bool = false
    
    // MARK: Private Properties: Shadow for ContentView
    @IBInspectable var contentViewShadowEnabled: Bool = true
    @IBInspectable var contentViewShadowColor: UIColor = UIColor.black
    @IBInspectable var contentViewShadowOffset: CGSize = CGSize.zero
    @IBInspectable var contentViewShadowOpacity: Float = 0.4
    @IBInspectable var contentViewShadowRadius: Float = 8.0
    
    // MARK: Public Properties: SideMenu
    @IBInspectable open var animationDuration: Float = 0.35
    @IBInspectable open var panGestureEnabled: Bool = true
    @IBInspectable open var panDirection: SideMenuPanDirection = .edge
    @IBInspectable open var type: SideMenuType = .scale
    @IBInspectable open var panMinimumOpenThreshold: UInt = 60
    @IBInspectable open var menuViewControllerTransformation: CGAffineTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    @IBInspectable open var backgroundTransformation: CGAffineTransform = CGAffineTransform(scaleX: 1.7, y: 1.7)
    
    // MARK: Internal Private Properties
    
    weak var delegate: SideMenuDelegate?
    
    fileprivate var visible: Bool = false
    fileprivate var leftMenuVisible: Bool = false
    fileprivate var rightMenuVisible: Bool = false
    fileprivate var originalPoint: CGPoint = CGPoint()
    fileprivate var didNotifyDelegate: Bool = false
    
    fileprivate let iOS8: Bool = kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_7_1
    
    fileprivate let menuViewContainer: UIView = UIView()
    fileprivate let contentViewContainer: UIView = UIView()
    fileprivate let contentButton: UIButton = UIButton()
    
    fileprivate let backgroundImageView: UIImageView = UIImageView()
    
    // MARK: Public Properties
    
    @IBInspectable open var backgroundImage: UIImage? {
        willSet {
            if let bckImage = newValue {
                backgroundImageView.image = bckImage
            }
        }
    }
    
    open var contentViewController: UIViewController? {
        willSet  {
            setupViewController(contentViewContainer, targetViewController: newValue)
        }
        didSet {
            if let controller = oldValue {
                hideViewController(controller)
            }
            setupContentViewShadow()
            if visible {
                setupContentViewControllerMotionEffects()
            }
        }
    }
    
    open var leftMenuViewController: UIViewController? {
        willSet  {
            setupViewController(menuViewContainer, targetViewController: newValue)
        }
        didSet {
            if let controller = oldValue {
                hideViewController(controller)
            }
            setupMenuViewControllerMotionEffects()
            view.bringSubview(toFront: contentViewContainer)
        }
    }
    
    open var rightMenuViewController: UIViewController? {
        willSet  {
            setupViewController(menuViewContainer, targetViewController: newValue)
        }
        didSet {
            if let controller = oldValue {
                hideViewController(controller)
            }
            setupMenuViewControllerMotionEffects()
            view.bringSubview(toFront: contentViewContainer)
        }
    }
    
    
    // MARK: Initializers
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(contentViewController: UIViewController, leftMenuViewController: UIViewController) {
        self.init()
        self.contentViewController = contentViewController
        self.leftMenuViewController = leftMenuViewController
        
    }
    
    public convenience init(contentViewController: UIViewController, rightMenuViewController: UIViewController) {
        self.init()
        self.contentViewController = contentViewController
        self.rightMenuViewController = rightMenuViewController
    }
    
    public convenience init(contentViewController: UIViewController, leftMenuViewController: UIViewController, rightMenuViewController: UIViewController) {
        self.init()
        self.contentViewController = contentViewController
        self.leftMenuViewController = leftMenuViewController
        self.rightMenuViewController = rightMenuViewController
    }
    
    // MARK: Present / Hide Menu ViewControllers
    
    func _presentLeftMenuViewController() {
        presentMenuViewContainerWithMenuViewController(leftMenuViewController)
        showLeftMenuViewController()
    }
    
    func _presentRightMenuViewController() {
        presentMenuViewContainerWithMenuViewController(rightMenuViewController)
        showRightMenuViewController()
    }
    
    open func hideMenuViewController() {
        hideMenuViewController(true)
    }
    
    
    fileprivate func showRightMenuViewController() {
        
        if let viewController = rightMenuViewController {
            
            showMenuViewController(.right, menuViewController: viewController)
            
            UIView.animate(withDuration: TimeInterval(animationDuration), animations: {[unowned self] () -> Void in
                
                self.animateMenuViewController(.right)
                
                self.menuViewContainer.alpha = 1
                self.contentViewContainer.alpha = CGFloat(self.contentViewFadeOutAlpha)
                
                
                }, completion: {[unowned self] (Bool) -> Void in
                    self.animateMenuViewControllerCompletion(.right, menuViewController: viewController)
                })
            statusBarNeedsAppearanceUpdate()
        }
        
    }
    
    fileprivate func showLeftMenuViewController() {
        
        if let viewController = leftMenuViewController {
            
            showMenuViewController(.left, menuViewController: viewController)
            
            UIView.animate(withDuration: TimeInterval(animationDuration), animations: {[unowned self] () -> Void in
                
                self.animateMenuViewController(.left)
                
                self.menuViewContainer.alpha = 1
                self.contentViewContainer.alpha = CGFloat(self.contentViewFadeOutAlpha)
                
                }, completion: {[unowned self] (Bool) -> Void in
                    self.animateMenuViewControllerCompletion(.left, menuViewController: viewController)
                })
            
            statusBarNeedsAppearanceUpdate()
            
        }
    }
    
    fileprivate func showMenuViewController(_ side: SideMenuSide, menuViewController: UIViewController) {
        
        menuViewController.view.isHidden = false
        
        switch side {
        case .left:
            leftMenuViewController?.beginAppearanceTransition(true, animated: true)
            rightMenuViewController?.view.isHidden = true
        case .right:
            rightMenuViewController?.beginAppearanceTransition(true, animated: true)
            leftMenuViewController?.view.isHidden = true
        }
        
        if endAllEditing {
            view.window?.endEditing(true)
        }else {
            setupUserInteractionForContentButtonAndTargetViewControllerView(true, targetViewControllerViewInteractive: false)
        }
        
        setupContentButton()
        setupContentViewShadow()
        resetContentViewScale()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    
    fileprivate func animateMenuViewController(_ side: SideMenuSide) {
        
        if type == .scale {
            contentViewContainer.transform = CGAffineTransform(scaleX: CGFloat(contentViewScaleValue), y: CGFloat(contentViewScaleValue))
        } else {
            contentViewContainer.transform = CGAffineTransform.identity
        }
        
        if side == .left {
            let contentWidth = CGFloat(view.frame.width) / 2
            let centerX = CGFloat(view.frame.width) + contentWidth - CGFloat(contentViewInPortraitOffsetCenterX)
            let centerY = contentViewContainer.frame.height / 2 + CGFloat(contentViewInPortraitOffsetCenterX)
            
            contentViewContainer.center = CGPoint(x: centerX, y: centerY)
        } else {
        
            let centerX = CGFloat(-self.contentViewInPortraitOffsetCenterX)
            
            contentViewContainer.center = CGPoint(x: centerX, y: contentViewContainer.center.y)
        }
        
        menuViewContainer.transform = CGAffineTransform.identity
        
        if scaleBackgroundImageView {
            if let _ = backgroundImage {
                backgroundImageView.transform = CGAffineTransform.identity
            }
        }
    }
    
    fileprivate func animateMenuViewControllerCompletion(_ side: SideMenuSide, menuViewController: UIViewController) {
        
        if !visible {
            self.delegate?.sideMenuDidShowMenuViewController?(self, menuViewController: menuViewController)
        }
        
        visible = true
        
        switch side {
        case .left:
            leftMenuViewController?.endAppearanceTransition()
            leftMenuVisible = true
        case .right:
            if contentViewContainer.frame.size.width == view.bounds.size.width &&
                contentViewContainer.frame.size.height == view.bounds.size.height &&
                contentViewContainer.frame.origin.x == 0 &&
                contentViewContainer.frame.origin.y == 0 {
                    visible = false
            }
            rightMenuVisible = visible
            rightMenuViewController?.endAppearanceTransition()
        }
        
        
        UIApplication.shared.endIgnoringInteractionEvents()
        setupContentViewControllerMotionEffects()
    }
    
    fileprivate func presentMenuViewContainerWithMenuViewController(_ menuViewController: UIViewController?) {
        
        menuViewContainer.transform = CGAffineTransform.identity
        menuViewContainer.frame = view.bounds
        
        if scaleBackgroundImageView {
            if backgroundImage != nil {
                backgroundImageView.transform = CGAffineTransform.identity
                backgroundImageView.frame = view.bounds
                backgroundImageView.transform = backgroundTransformation
            }
        }
        
        if scaleMenuView {
            menuViewContainer.transform = menuViewControllerTransformation
        }
        menuViewContainer.alpha = fadeMenuView ? CGFloat(startMenuAlpha) : 1
        
        if let viewController = menuViewController {
            delegate?.sideMenuWillShowMenuViewController?(self, menuViewController: viewController)
        }
        
    }
    
    fileprivate func hideMenuViewController(_ animated: Bool) {
        
        let isRightMenuVisible: Bool = rightMenuVisible
        
        let visibleMenuViewController: UIViewController? = isRightMenuVisible ? rightMenuViewController : leftMenuViewController
        
        visibleMenuViewController?.beginAppearanceTransition(true, animated: true)
        
        if isRightMenuVisible, let viewController = rightMenuViewController {
            delegate?.sideMenuWillHideMenuViewController?(self, menuViewController: viewController)
        }
        
        if !isRightMenuVisible, let viewController = leftMenuViewController {
            delegate?.sideMenuWillHideMenuViewController?(self, menuViewController: viewController)
        }
        
        if !endAllEditing {
            setupUserInteractionForContentButtonAndTargetViewControllerView(false, targetViewControllerViewInteractive: true)
        }
        
        visible = false
        leftMenuVisible = false
        rightMenuVisible = false
        contentButton.removeFromSuperview()
        
        let animationsClosure: () -> () =  {[unowned self] () -> () in
            
            self.contentViewContainer.transform = CGAffineTransform.identity
            self.contentViewContainer.frame = self.view.bounds
            
            if self.scaleMenuView {
                self.menuViewContainer.transform = self.menuViewControllerTransformation
            }
            self.menuViewContainer.alpha = self.fadeMenuView ? CGFloat(self.startMenuAlpha) : 1
            self.contentViewContainer.alpha = CGFloat(self.contentViewFadeOutAlpha)
            
            if self.scaleBackgroundImageView {
                if self.backgroundImage != nil {
                    self.backgroundImageView.transform = self.backgroundTransformation
                }
            }
            
            if self.parallaxEnabled {
                self.removeMotionEffects(self.contentViewContainer)
            }
            
        }
        
        let completionClosure: () -> () =  {[weak self] () -> () in
            
            visibleMenuViewController?.endAppearanceTransition()
            
            if isRightMenuVisible, let viewController = self?.rightMenuViewController {
                self?.delegate?.sideMenuDidHideMenuViewController?(self!, menuViewController: viewController)
            }
            
            if !isRightMenuVisible, let viewController = self?.leftMenuViewController {
                self?.delegate?.sideMenuDidHideMenuViewController?(self!, menuViewController: viewController)
            }
            
        }
        
        if animated {
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            UIView.animate(withDuration: TimeInterval(animationDuration), animations: { () -> Void in
                
                animationsClosure()
                
                }, completion: { (Bool) -> Void in
                    completionClosure()
                    
                    UIApplication.shared.endIgnoringInteractionEvents()
            })
            
        }else {
            
            animationsClosure()
            completionClosure()
        }
        
        statusBarNeedsAppearanceUpdate()
        
    }
    
    // MARK: ViewController life cycle
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        if iOS8 {
            if let cntentViewStoryboardID = contentViewStoryboardID {
                contentViewController = storyboard?.instantiateViewController(withIdentifier: cntentViewStoryboardID)
                
            }
            if let lftViewStoryboardID = leftMenuViewStoryboardID {
                leftMenuViewController = storyboard?.instantiateViewController(withIdentifier: lftViewStoryboardID)
            }
            if let rghtViewStoryboardID = rightMenuViewStoryboardID {
                rightMenuViewController = storyboard?.instantiateViewController(withIdentifier: rghtViewStoryboardID)
            }
        }
        
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        menuViewContainer.frame = view.bounds;
        menuViewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        menuViewContainer.alpha = fadeMenuView ? CGFloat(startMenuAlpha) : 1
        
        contentViewContainer.frame = view.bounds
        contentViewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setupViewController(contentViewContainer, targetViewController: contentViewController)
        setupViewController(menuViewContainer, targetViewController: leftMenuViewController)
        setupViewController(menuViewContainer, targetViewController: rightMenuViewController)
        
        if panGestureEnabled {
            view.isMultipleTouchEnabled = false
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SideMenu.panGestureRecognized(_:)))
            panGestureRecognizer.delegate = self
            view.addGestureRecognizer(panGestureRecognizer)
        }
        
        if let _ = backgroundImage {
            if scaleBackgroundImageView {
                backgroundImageView.transform = backgroundTransformation
            }
            backgroundImageView.frame = view.bounds
            backgroundImageView.contentMode = .scaleAspectFill;
            backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
            view.addSubview(backgroundImageView)
        }
        
        view.addSubview(menuViewContainer)
        view.addSubview(contentViewContainer)
        
        setupMenuViewControllerMotionEffects()
        setupContentViewShadow()
        
    }
    
    
    // MARK: Setup
    
    fileprivate func setupViewController(_ targetView: UIView, targetViewController: UIViewController?) {
        if let viewController = targetViewController {
            
            addChildViewController(viewController)
            viewController.view.frame = view.bounds
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            targetView.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
            
        }
    }
    
    fileprivate func hideViewController(_ targetViewController: UIViewController) {
        targetViewController.willMove(toParentViewController: nil)
        targetViewController.view.removeFromSuperview()
        targetViewController.removeFromParentViewController()
    }
    
    // MARK: Layout
    
    fileprivate func setupContentButton() {
        
        if let _ = contentButton.superview {
            return
        } else {
            contentButton.addTarget(self, action: #selector(SideMenu.hideMenuViewController as (SideMenu) -> () -> ()), for:.touchUpInside)
            contentButton.autoresizingMask = UIViewAutoresizing()
            contentButton.frame = contentViewContainer.bounds
            contentButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentButton.tag = 101
            contentViewContainer.addSubview(contentButton)
        }
        
    }
    
    fileprivate func statusBarNeedsAppearanceUpdate() {
        
        if self.responds(to: #selector(UIViewController.setNeedsStatusBarAppearanceUpdate)) {
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
    fileprivate func setupContentViewShadow() {
        
        if contentViewShadowEnabled {
            let layer: CALayer = contentViewContainer.layer
            let path: UIBezierPath = UIBezierPath(rect: layer.bounds)
            layer.shadowPath = path.cgPath
            layer.shadowColor = contentViewShadowColor.cgColor
            layer.shadowOffset = contentViewShadowOffset
            layer.shadowOpacity = contentViewShadowOpacity
            layer.shadowRadius = CGFloat(contentViewShadowRadius)
        }
        
    }
    
    // MARK: Helper Functions
    
    fileprivate func resetContentViewScale() {
        let t: CGAffineTransform = contentViewContainer.transform
        let scale: CGFloat = sqrt(t.a * t.a + t.c * t.c)
        let frame: CGRect = contentViewContainer.frame
        contentViewContainer.transform = CGAffineTransform.identity
        contentViewContainer.transform = CGAffineTransform(scaleX: scale, y: scale)
        contentViewContainer.frame = frame
    }
    
    fileprivate func setupUserInteractionForContentButtonAndTargetViewControllerView(_ contentButtonInteractive: Bool, targetViewControllerViewInteractive: Bool) {
        
        if let viewController = contentViewController {
            for view in viewController.view.subviews {
                if view.tag == 101 {
                    view.isUserInteractionEnabled = contentButtonInteractive
                }else {
                    view.isUserInteractionEnabled = targetViewControllerViewInteractive
                }
            }
        }
        
    }
    
    // MARK: Motion Effects (Private)
    
    fileprivate func removeMotionEffects(_ targetView: UIView) {
        let targetViewMotionEffects = targetView.motionEffects
        for effect in targetViewMotionEffects {
            targetView.removeMotionEffect(effect)
        }
        
    }
    
    fileprivate func setupMenuViewControllerMotionEffects() {
        
        if parallaxEnabled {
            removeMotionEffects(menuViewContainer)
            
            // We need to refer to self in closures!
            UIView.animate(withDuration: 0.2, animations: { [unowned self] () -> Void in
                
                let interpolationHorizontal: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
                interpolationHorizontal.minimumRelativeValue = self.parallaxContentMinimumRelativeValue
                interpolationHorizontal.maximumRelativeValue = self.parallaxContentMaximumRelativeValue
                
                let interpolationVertical: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
                interpolationHorizontal.minimumRelativeValue = self.parallaxContentMinimumRelativeValue
                interpolationHorizontal.maximumRelativeValue = self.parallaxContentMaximumRelativeValue
                
                self.menuViewContainer.addMotionEffect(interpolationHorizontal)
                self.menuViewContainer.addMotionEffect(interpolationVertical)
                
                })
        }
    }
    
    
    fileprivate func setupContentViewControllerMotionEffects() {
        
        if parallaxEnabled {
            
            removeMotionEffects(contentViewContainer)
            
            // We need to refer to self in closures!
            UIView.animate(withDuration: 0.2, animations: { [unowned self] () -> Void in
                
                let interpolationHorizontal: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
                interpolationHorizontal.minimumRelativeValue = self.parallaxContentMinimumRelativeValue
                interpolationHorizontal.maximumRelativeValue = self.parallaxContentMaximumRelativeValue
                
                let interpolationVertical: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
                interpolationHorizontal.minimumRelativeValue = self.parallaxContentMinimumRelativeValue
                interpolationHorizontal.maximumRelativeValue = self.parallaxContentMaximumRelativeValue
                
                self.contentViewContainer.addMotionEffect(interpolationHorizontal)
                self.contentViewContainer.addMotionEffect(interpolationVertical)
                
                })
        }
        
        
    }
    
    // MARK: View Controller Rotation handler
    
    open override var shouldAutorotate : Bool {
        
        if let cntViewController = contentViewController {
            
            return cntViewController.shouldAutorotate
        }
        return false
        
    }
    
    open override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        if visible {
            
            menuViewContainer.bounds = view.bounds
            contentViewContainer.transform = CGAffineTransform.identity
            contentViewContainer.frame = view.bounds
            
            if type == .scale {
                contentViewContainer.transform = CGAffineTransform(scaleX: CGFloat(contentViewScaleValue), y: CGFloat(contentViewScaleValue))
            } else {
                contentViewContainer.transform = CGAffineTransform.identity
            }
            
            var center: CGPoint
            if leftMenuVisible {
                
                let centerX = CGFloat(contentViewInPortraitOffsetCenterX) + CGFloat(view.frame.width)
                
                center = CGPoint(x: centerX, y: contentViewContainer.center.y)
                
            } else {
                
                let centerX = CGFloat(-self.contentViewInPortraitOffsetCenterX)
                
                center = CGPoint(x: centerX, y: contentViewContainer.center.y)
            }
            
            contentViewContainer.center = center
        }
        
        setupContentViewShadow()
        
    }
    
    
    // MARK: Status Bar Appearance Management
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        
        var style: UIStatusBarStyle
        
        switch statusBarStyle {
        case .hidden:
            style = .default
        case .black:
            style = .default
        case .light:
            style = .lightContent
        }
        
        if visible || contentViewContainer.frame.origin.y <= 0, let cntViewController = contentViewController {
            style = cntViewController.preferredStatusBarStyle
        }
        
        return style
        
    }
    
    open override var prefersStatusBarHidden : Bool {
        
        var statusBarHidden: Bool
        
        switch statusBarStyle {
        case .hidden:
            statusBarHidden = true
        default:
            statusBarHidden = false
        }
        
        if visible || contentViewContainer.frame.origin.y <= 0, let cntViewController = contentViewController {
            statusBarHidden = cntViewController.prefersStatusBarHidden
        }
        
        return statusBarHidden
    }
    
    
    open override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        
        var statusBarAnimation: UIStatusBarAnimation = .none
        
        if let cntViewController = contentViewController, let leftMenuViewController = leftMenuViewController {
            
            statusBarAnimation = visible ? leftMenuViewController.preferredStatusBarUpdateAnimation : cntViewController.preferredStatusBarUpdateAnimation
            
            if contentViewContainer.frame.origin.y > 10 {
                statusBarAnimation = leftMenuViewController.preferredStatusBarUpdateAnimation
            } else {
                statusBarAnimation = cntViewController.preferredStatusBarUpdateAnimation
            }
        }
        
        if let cntViewController = contentViewController, let rghtMenuViewController = rightMenuViewController {
            
            statusBarAnimation = visible ? rghtMenuViewController.preferredStatusBarUpdateAnimation : cntViewController.preferredStatusBarUpdateAnimation
            
            if contentViewContainer.frame.origin.y > 10 {
                statusBarAnimation = rghtMenuViewController.preferredStatusBarUpdateAnimation
            } else {
                statusBarAnimation = cntViewController.preferredStatusBarUpdateAnimation
            }
        }
        
        return statusBarAnimation
        
    }
    
    
    // MARK: UIGestureRecognizer Delegate (Private)
    
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if interactivePopGestureRecognizerEnabled,
            let viewController = contentViewController as? UINavigationController, viewController.viewControllers.count > 1 && viewController.interactivePopGestureRecognizer!.isEnabled {
                return false
        }
        
        if gestureRecognizer is UIPanGestureRecognizer && !visible {
            
            switch panDirection {
            case .everyWhere:
                return true
            case .edge:
                let point = touch.location(in: gestureRecognizer.view)
                return point.x < 20.0 || point.x > view.frame.size.width - 20.0
            case .rect(let rect):
                let point = touch.location(in: gestureRecognizer.view)
                return point.x > rect.origin.x
                    && point.y > rect.origin.y
                    && point.x < rect.origin.x + rect.size.width
                    && point.y < rect.origin.y + rect.size.height
            case .edgeAndRect(let rect):
                let point = touch.location(in: gestureRecognizer.view)
                return point.x < 20.0 || point.x > view.frame.size.width - 20.0
                    || point.x > rect.origin.x
                    && point.y > rect.origin.y
                    && point.x < rect.origin.x + rect.size.width
                    && point.y < rect.origin.y + rect.size.height

            }
        }
        
        return true
    }
    
    func panGestureRecognized(_ recognizer: UIPanGestureRecognizer) {
        
        delegate?.sideMenuDidRecognizePanGesture?(self, recongnizer: recognizer)
        
        if !panGestureEnabled {
            return
        }
        
        var point: CGPoint = recognizer.translation(in: view)
        
        if recognizer.state == .began {
            setupContentViewShadow()
            
            originalPoint = CGPoint(x: contentViewContainer.center.x - contentViewContainer.bounds.width / 2.0,
                y: contentViewContainer.center.y - contentViewContainer.bounds.height / 2.0)
            menuViewContainer.transform = CGAffineTransform.identity
            
            if (scaleBackgroundImageView) {
                backgroundImageView.transform = CGAffineTransform.identity
                backgroundImageView.frame = view.bounds
            }
            
            menuViewContainer.frame = view.bounds
            setupContentButton()
            
            if endAllEditing {
                view.window?.endEditing(true)
            }else {
                setupUserInteractionForContentButtonAndTargetViewControllerView(true, targetViewControllerViewInteractive: false)
            }
            
            didNotifyDelegate = false
        }
        
        if recognizer.state == .changed {
            
            var delta: CGFloat = 0.0
            if visible {
                delta = originalPoint.x != 0 ? (point.x + originalPoint.x) / originalPoint.x : 0
            } else {
                delta = point.x / view.frame.size.width
            }
            
            delta = min(fabs(delta), 1.6)
            
            var contentViewScale: CGFloat = type == .scale ? 1 + ((CGFloat(contentViewScaleValue) - 1) * delta) : 1
            
            var contentOffsetY = CGFloat(contentViewInPortraitOffsetCenterY)
            contentOffsetY = visible ? -((1-delta)*contentOffsetY) : delta*contentOffsetY
            
            var backgroundViewScale: CGFloat = backgroundTransformation.a - ((backgroundTransformation.a - 1) * delta)
            var menuViewScale: CGFloat = menuViewControllerTransformation.a - ((menuViewControllerTransformation.a - 1) * delta)
            
            if !bouncesHorizontally {
                contentViewScale = min(contentViewScale, CGFloat(contentViewScaleValue))
                backgroundViewScale = min(backgroundViewScale, 1.0)
                menuViewScale = min(menuViewScale, 1.0)
            }
            
            let menuAlphaDelta = (delta * CGFloat(1.0 - startMenuAlpha)) + CGFloat(startMenuAlpha)
            menuViewContainer.alpha = fadeMenuView ? menuAlphaDelta : 1
            contentViewContainer.alpha = 1 - (1 - CGFloat(contentViewFadeOutAlpha)) * delta
            
            if scaleBackgroundImageView {
                backgroundImageView.transform = CGAffineTransform(scaleX: backgroundViewScale, y: backgroundViewScale)
            }
            
            if scaleMenuView {
                menuViewContainer.transform = CGAffineTransform(scaleX: menuViewScale, y: menuViewScale)
            }
            
            if scaleBackgroundImageView && backgroundViewScale < 1 {
                backgroundImageView.transform = CGAffineTransform.identity
            }
            
            if bouncesHorizontally && visible {
                if contentViewContainer.frame.origin.x > contentViewContainer.frame.size.width / 2.0 {
                    point.x = min(0.0, point.x)
                }
                
                if contentViewContainer.frame.origin.x < -(contentViewContainer.frame.size.width / 2.0) {
                    point.x = max(0.0, point.x)
                }
                
            }
            
            // Limit size
            if point.x < 0 {
                point.x = max(point.x, -UIScreen.main.bounds.size.height)
            } else {
                point.x = min(point.x, UIScreen.main.bounds.size.height)
            }
            
            recognizer.setTranslation(point, in: view)
            
            if !didNotifyDelegate {
                if point.x > 0  && !visible, let viewController = leftMenuViewController {
                    delegate?.sideMenuWillShowMenuViewController?(self, menuViewController: viewController)
                }
                if point.x < 0 && !visible, let viewController = rightMenuViewController {
                    delegate?.sideMenuWillShowMenuViewController?(self, menuViewController: viewController)
                }
                
                didNotifyDelegate = true
            }
            
            contentViewContainer.transform = CGAffineTransform(scaleX: contentViewScale, y: contentViewScale)
            contentViewContainer.transform = contentViewContainer.transform.translatedBy(x: point.x, y: contentOffsetY)
            
            leftMenuViewController?.view.isHidden = contentViewContainer.frame.origin.x < 0
            rightMenuViewController?.view.isHidden = contentViewContainer.frame.origin.x > 0
            
            if  leftMenuViewController == nil && contentViewContainer.frame.origin.x > 0 {
                contentViewContainer.transform = CGAffineTransform.identity
                contentViewContainer.frame = view.bounds
                visible = false
                leftMenuVisible = false
            } else if self.rightMenuViewController == nil && contentViewContainer.frame.origin.x < 0 {
                contentViewContainer.transform = CGAffineTransform.identity
                contentViewContainer.frame = view.bounds
                visible = false
                rightMenuVisible = false
            }
            
            statusBarNeedsAppearanceUpdate()
        }
        
        if recognizer.state == .ended {
            
            didNotifyDelegate = false
            if panMinimumOpenThreshold > 0 &&
                contentViewContainer.frame.origin.x < 0 &&
                contentViewContainer.frame.origin.x > -CGFloat(panMinimumOpenThreshold) ||
                contentViewContainer.frame.origin.x > 0 &&
                contentViewContainer.frame.origin.x < CGFloat(panMinimumOpenThreshold)  {
                    
                    hideMenuViewController()
                    
            }
            else if contentViewContainer.frame.origin.x == 0 {
                hideMenuViewController(false)
            }
                
            else if recognizer.velocity(in: view).x > 0 {
                if contentViewContainer.frame.origin.x < 0 {
                    hideMenuViewController()
                } else if leftMenuViewController != nil {
                    showLeftMenuViewController()
                }
            }
            else {
                if contentViewContainer.frame.origin.x < 20 &&  rightMenuViewController != nil{
                    showRightMenuViewController()
                } else {
                    hideMenuViewController()
                }
            }
            
        }
        
    }
    
}
