//
//  CDNavigationController.swift
//  CDNavigation
//
//  Created by Littlefox iOS Developer on 2023/08/24.
//

import UIKit
import SwiftUI

public class CDNavigationController: UINavigationController {
    
    let aniTime: Double = 0.5
    
    public enum Action: Equatable{
        case pop
        case dismiss
        case root
    }
    
    public var action: Action?{
        didSet{
            if let action = action{
                switch action {
                case .pop:
                    self.popViewController(animated: true)
                    break
                case .dismiss:
                    self.dismiss(animated: true)
                    break
                case .root:
                    self.popToRootViewController(animated: true)
                    break
                }
            }
        }
    }
  
    public typealias Event = () -> Void
    

    public enum NavigationBarBackgroundType: Equatable{
        case image(image: UIImage)
        case paint(color: UIColor)
    }
    
    public struct FontInfo : Equatable{
        let name: String?
        let size: CGFloat
        
        public init(name: String? = nil, size: CGFloat) {
            self.name = name
            self.size = size
        }
        
        var uiFont: UIFont?{
            if let name = name {
                return UIFont(name: name, size: size)
            }else{
                return UIFont.systemFont(ofSize: size)
            }
            
        }
    }
    
    public enum NavigationBarTitleType: Equatable{
        case image(image: UIImage)
        case text(title: String?, subTitle: String?, color: UIColor?, font: FontInfo?, subTitleFont: FontInfo?)
        var title: String?{
            switch self {
            case .text(let title,_, _,_,_):
                return title
            default:
                return nil
            }
        }
        
        var subTitle: String?{
            switch self {
            case .text(_,let subTitle, _,_,_):
                return subTitle
            default:
                return nil
            }
        }
        var fontInfo: FontInfo?{
            switch self{
            case .text(_,_,_, let font,_):
                return font
            default:
                return nil
            }
        }
        
        var subFontInfo: FontInfo?{
            switch self{
            case .text(_,_,_,_,let font):
                return font
            default:
                return nil
            }
        }
        
        var color: UIColor?{
            switch self{
            case .text(_,_,let color,_,_):
                return color
            default:
                return nil
            }
            
        }
        
        var isImage: Bool{
            switch self {
            case .image:
                return true
            case .text:
                return false
            }
        }
        
        var image: UIImage?{
            switch self {
            case .image(let image):
                return image
            case .text:
                return nil
            }
        }
        
    }
    
    private var backEvent: Event?
    private  var closeEvent: Event?

    
    private let navigationBarHeight: CGFloat
    private var naviBar: UIImageView?
    
    private var backBtn: UIButton?
    private var closeBtn: UIButton?
    
    private var titleLabel: UILabel?
    private var subTitleLabel: UILabel?
    
    private var titleImageView: UIImageView?
    
    private var statusbarView: UIView!
    private var fontInfo: FontInfo!
    private var subFontInfo: FontInfo?

    private var isInit: Bool = false
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public override var prefersStatusBarHidden: Bool{
        self.isStatusBarHidden
    }
    
    public override var prefersHomeIndicatorAutoHidden: Bool{
        true
    }
    
    var isStatusBarHidden: Bool = false{
        didSet{
            self.statusbarView.isHidden = self.isStatusBarHidden
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var isBackBtnEnable: Bool = true{
        didSet{
            self.backBtn?.isEnabled = self.isBackBtnEnable
        }
    }
    
    var isCloseBtnEnable: Bool = true{
        didSet{
            self.closeBtn?.isEnabled = self.isCloseBtnEnable
        }
    }
    
    
    var isNaviBarHidden: Bool = false{
        didSet{
//            UIView.animate(withDuration: 0.3) {
                self.navigationBar.isHidden = self.isNaviBarHidden
                if self.isNaviBarHidden{
                    self.naviBar?.frame.origin.y = -(self.statusBarHeight + UINavigationController().navigationBar.frame.size.height)
                    self.additionalSafeAreaInsets.top = 0
                    self.naviBar?.alpha = 0
                }else{
                    self.naviBar?.frame.origin.y = self.statusBarHeight
                    self.additionalSafeAreaInsets.top = self.navigationBarHeight - UINavigationController().navigationBar.frame.size.height
                    
                    self.naviBar?.alpha = 1
                }
//            }
        }
    }
    
    
    var navigationBarBackgroundType: NavigationBarBackgroundType = .paint(color: .clear){
        didSet{
            switch navigationBarBackgroundType {
            case .image(let image):
                self.naviBar?.image = image
                break
            case .paint(let color):
                UIView.animate(withDuration: 0.1) {

                    self.naviBar?.backgroundColor = color
                }
                
                break
            }
        }
    }
    
    
    var isBackBtnHidden: Bool = false{
        didSet{
            
            guard let backBtn = self.backBtn else{
                return
            }
            
            backBtn.isEnabled = false
            
            UIView.animate(withDuration: aniTime, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 0.1, options: .curveEaseOut) {
                if self.isBackBtnHidden{
                    backBtn.frame.origin.x = -backBtn.frame.size.width
                }else{
                    let left = backBtn.frame.size.width*(42.0/110)
                    backBtn.frame.origin.x = left
                }
            } completion: { _ in
                backBtn.isEnabled = true
            }
        }
    }
    
    var backImage: UIImage? {
        didSet{
            if oldValue == self.backImage{
                return
            }
            
            guard let backBtn = self.backBtn else{
                return
            }
            
            guard let image = self.backImage else{
                return
            }
            
            backBtn.isEnabled = false
            UIView.animate(withDuration: aniTime/2) {
                backBtn.frame.origin.x = -backBtn.frame.size.width
            } completion: { _ in
                backBtn.setImage(image, for: .normal)
                if self.isBackBtnHidden == false {
                    UIView.animate(withDuration: self.aniTime/2.0) {
                        let left = backBtn.frame.size.width*(42.0/110)
                        backBtn.frame.origin.x = left
                    }
                }
                backBtn.isEnabled = true
            }
        }
    }
    
    var isCloseBtnHidden: Bool = false{
        didSet{
            
            guard let closeBtn = self.closeBtn else{
                return
            }

            closeBtn.isEnabled = false
            UIView.animate(withDuration: aniTime, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 0.1, options: .curveEaseOut) {
                let tW = (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeLeft) ? self.view.frame.size.height : self.view.frame.size.width
                if self.isCloseBtnHidden{
                    closeBtn.frame.origin.x = tW
                }else{
                    let left = closeBtn.frame.size.width*(42.0/110)
                    closeBtn.frame.origin.x = tW - left - closeBtn.frame.size.width
                }
            } completion: { _ in
                closeBtn.isEnabled = true
            }
        }
    }
    
    var closeImage: UIImage? {
        didSet{
            if oldValue == self.closeImage{
                return
            }
            
            guard let closeBtn = self.closeBtn else{
                return
            }
            
            guard let image = self.closeImage else{
                return
            }
            
            closeBtn.isEnabled = false
            UIView.animate(withDuration: 0.15) {
                closeBtn.frame.origin.x = self.view.frame.size.width
            } completion: { _ in
                closeBtn.setImage(image, for: .normal)
                if self.isCloseBtnHidden == false {
                    UIView.animate(withDuration: 0.15) {
                        let left = closeBtn.frame.size.width*(42.0/110)
                        closeBtn.frame.origin.x = self.view.frame.size.width - left - closeBtn.frame.size.width
                    }
                }
                
                closeBtn.isEnabled = true
            }
        }
    }
    
   
    
    var navigationBarTitleType: NavigationBarTitleType?{
        set{
            switch newValue{
            case .text(let title, let subTitle, let color, let fontInfo,let subFontInfo):
                
                UIView.animate(withDuration: 0.1) {
                    if title == nil {
                        self.titleLabel?.isHidden = true
                    }else{
                        self.titleLabel?.isHidden = false
                    }
                    
                    if subTitle == nil {
                        self.subTitleLabel?.isHidden = true
                    }else{
                        self.subTitleLabel?.isHidden = false
                    }
                    
//
                } completion: { _ in
                    
                    self.titleLabel?.text = title
                    self.titleLabel?.textColor = color
                    self.titleLabel?.font = fontInfo?.uiFont
                    
                    self.titleLabel?.sizeToFit()
                    self.titleLabel?.center.x = self.naviBar!.frame.size.width/2
                    
                    if let subTitle = subTitle{
                        
                        self.subTitleLabel?.text = subTitle
                        self.subTitleLabel?.textColor = color
                        self.subTitleLabel?.font = subFontInfo?.uiFont
                        
                        self.subTitleLabel?.sizeToFit()
                        
                        UIView.animate(withDuration: 0.1) {
                            if let _ = title {
                                self.titleLabel?.isHidden = false
                            }
//                            self.titleLabel?.alpha = 1
                            self.subTitleLabel?.isHidden = false
                            self.subTitleLabel?.center.x = self.titleLabel?.center.x ?? 0
                            
                            
                            self.titleLabel?.frame.origin.y = self.navigationBarHeight*0.5 + self.statusBarHeight//(self.subTitleLabel?.frame.origin.y ?? 0) + (self.subTitleLabel?.frame.size.height ?? 0)
        //                    self.subTitleLabel?.frame.size.height = self.navigationBarHeight*(52/183)
                            self.subTitleLabel?.frame.origin.y = (self.titleLabel?.frame.origin.y ?? 0) - (self.subTitleLabel?.frame.height ?? 0)//self.navigationBarHeight*(18/183) + self.statusBarHeight
                        }
                    }else{
                        UIView.animate(withDuration: 0.1) {
                            self.titleLabel?.frame.origin.y = (self.navigationBarHeight - (self.titleLabel?.frame.size.height ?? 0))/2 + self.statusBarHeight
                            self.subTitleLabel?.isHidden = true
                            if let _ = title {
                                self.titleLabel?.isHidden = false
                            }
                        }
                    }
                }
                break
            case .image(_):
                self.titleLabel?.isHidden = true
                self.subTitleLabel?.isHidden = true
            default:
                break
            }
        }
        get{
            .text(title: self.titleLabel?.text, subTitle: subTitleLabel?.text, color: self.titleLabel?.textColor, font: self.fontInfo, subTitleFont: self.subFontInfo)
        }
    }
    
    public var statusBarColor: UIColor?{
        didSet{
            guard let statusBarColor = statusBarColor else{
                return
            }
            self.setStatusBar(color: statusBarColor)
        }
    }
    
    public init(navigationBarHeight:CGFloat,
         navigationBarBackgroundType: NavigationBarBackgroundType,
         navigationBarTitleType: NavigationBarTitleType,
         statusBarColor: UIColor,
                isStatusBarHidden: Bool,
         closeImage: UIImage?,
         backImage: UIImage?,
         rootViewController: UIViewController) {
        self.navigationBarHeight = navigationBarHeight
        super.init(rootViewController: rootViewController)
        
        self.isStatusBarHidden = isStatusBarHidden
        self.additionalSafeAreaInsets.top = self.navigationBarHeight - UINavigationController().navigationBar.frame.size.height
        
        self.naviBar = UIImageView(frame: CGRect(origin: CGPoint(x: 0,
                                                                 y: self.statusBarHeight),
                                                 size: CGSize(width: self.view.frame.size.width,
                                                              height: self.navigationBarHeight)))
        self.naviBar?.isUserInteractionEnabled = true
        switch navigationBarBackgroundType {
        case .image(let image):
            self.naviBar?.image = image
            break
        case .paint(let color):
            self.naviBar?.backgroundColor = color
            break
        }
        self.view.addSubview(naviBar!)
        
        
        if let backImage = backImage {
            let btnHeight = (118.0/183.0)*self.navigationBarHeight
            let btnWidth = btnHeight*(backImage.size.width/backImage.size.height)
            let left = btnWidth*(42.0/110)
            let top = (self.navigationBarHeight - btnHeight)/2 - ((self.isStatusBarHidden && UIDevice.current.userInterfaceIdiom == .pad) ? self.statusBarHeight : 0)
            self.backBtn = UIButton(frame: CGRect(origin: CGPoint(x: left, y: top+statusBarHeight),
                                                   size: CGSize(width: btnWidth, height: btnHeight)))
            self.backBtn?.setImage(backImage, for: .normal)
            self.backBtn?.addTarget(self, action: #selector(backCallback(_:)), for: .touchUpInside)
            self.view.addSubview(self.backBtn!)
            self.backBtn?.adjustsImageWhenDisabled = false
            
        }
        
        if let closeImage = closeImage {
            let btnHeight = (118.0/183.0)*self.navigationBarHeight
            let btnWidth = btnHeight*(closeImage.size.width/closeImage.size.height)
            let left = btnWidth*(42.0/110)
            let top = (self.navigationBarHeight - btnHeight)/2 - ((self.isStatusBarHidden && UIDevice.current.userInterfaceIdiom == .pad) ? self.statusBarHeight : 0)
            self.closeBtn = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.size.width - left - btnWidth, y: top+statusBarHeight),
                                                   size: CGSize(width: btnWidth, height: btnHeight)))
            self.closeBtn?.setImage(closeImage, for: .normal)
            self.closeBtn?.addTarget(self, action: #selector(closeCallback(_:)), for: .touchUpInside)
            self.view.addSubview(self.closeBtn!)
            
            self.closeBtn?.adjustsImageWhenDisabled = false
        }
        
        self.titleLabel = UILabel()
        self.titleLabel?.frame.size.width = self.view.frame.size.width - ((self.backBtn?.frame.origin.x ?? 0) + (self.backBtn?.frame.size.width ?? 0))*2.1
        self.view.addSubview(self.titleLabel!)
        
        self.subTitleLabel = UILabel()
        self.view.addSubview(self.subTitleLabel!)
        
        self.titleImageView = UIImageView()
        self.view.addSubview(self.titleImageView!)
        
        if navigationBarTitleType.isImage{
            self.titleLabel?.isHidden = true
            self.subTitleLabel?.isHidden = true
            
            let h = self.navigationBarHeight*(76/183.0)
            let w =  h*(navigationBarTitleType.image!.size.width/navigationBarTitleType.image!.size.height)
            self.titleImageView?.image = navigationBarTitleType.image
            self.titleImageView?.frame.size = CGSize(width: w, height: h)
            self.titleImageView?.center.x = self.view.frame.size.width/2
//            self.titleImageView?.frame.origin.y = (self.navigationBarHeight - (self.closeBtn?.frame.size.height ?? 0))/2 + statusBarHeight
            self.titleImageView?.frame.origin.y = (self.navigationBarHeight - h)/2 + statusBarHeight
            
        }else{
            self.titleImageView?.isHidden = true
            
            self.titleLabel?.isHidden = false
            self.subTitleLabel?.isHidden = false
        }
        
        self.navigationBarTitleType = navigationBarTitleType
        self.fontInfo = navigationBarTitleType.fontInfo
        self.subFontInfo = navigationBarTitleType.subFontInfo
        
        
//        self.statusBarColor = statusBarColor
        self.statusbarView = UIView()
//        self.statusbarView.backgroundColor = statusBarColor
        self.statusbarView.isHidden = self.isStatusBarHidden
        self.view.addSubview(statusbarView)
        
        
        statusbarView.translatesAutoresizingMaskIntoConstraints = false
        statusbarView.heightAnchor
            .constraint(equalToConstant: statusBarHeight).isActive = true
        statusbarView.widthAnchor
            .constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        statusbarView.topAnchor
            .constraint(equalTo: self.view.topAnchor).isActive = true
        statusbarView.centerXAnchor
            .constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.navigationBar.backgroundColor = .clear
        
        self.isInit = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.naviBar?.frame = CGRect(origin: CGPoint(x: 0, y: self.statusBarHeight), size: CGSize(width: self.view.frame.size.width, height: navigationBarHeight))
        let type = self.navigationBarTitleType
        self.navigationBarTitleType = type
    }

    @objc private func backCallback(_ sender: UIButton){
        if let backEven = backEvent{
            backEven()
        }else{
            self.popViewController(animated: true)
        }
        
    }
    
    @objc private func closeCallback(_ sender: UIButton){
        if let closeEvent = closeEvent{
            closeEvent()
        }else{
            self.dismiss(animated: true)
        }
    }
    
    func setStatusBar(color: UIColor){
        self.statusbarView.backgroundColor = color
    }
    
    public func setBackEvent(event: Event?){
        self.backEvent = event
    }
    
    public func setCloseEvent(event: Event?){
        self.closeEvent = event
    }
}


public extension UIViewController{
    var statusBarHeight : CGFloat {
        if let safeFrame = UIApplication.shared.windows.first?.safeAreaInsets{
            return Swift.max(safeFrame.top, safeFrame.left)
        }
        return 0
    }
}


extension CDNavigationController: UINavigationControllerDelegate{
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
    }
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
}
