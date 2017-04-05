//
//  CameraViewController.swift
//  YHGallery
//
//  Created by hao yin on 2017/4/5.
//  Copyright © 2017年 hao yin. All rights reserved.
//

import UIKit
import GLKit
public typealias CamaraCatchImage = (UIImage?)->Void

public class CameraViewController: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
public class CameraView:UIView{
    private var screen:GLKView = GLKView(frame: UIScreen.main.bounds, context: EAGLContext(api: .openGLES2))
    private var layouted = false
    public let camera:Camera? = Camera()
    
    private var bottomBar:UIView = UIView()
    private var btn:UIButton = UIButton()
    public var imageDelegate:CamaraCatchImage?
    public override func didMoveToWindow() {
        if !layouted{
            loadScreen()
            loadBottomBar()
            loadCaptureBtn()
            
            self.screen.context = (camera?.context)!
            camera?.view = self.screen
            camera?.start(screenFrame: self.bounds)
            self.btn.addTarget(self, action: #selector(shutter), for: .touchUpInside)
        }
    }
    
    private func loadScreen(){
        self.addSubview(screen)
        screen.translatesAutoresizingMaskIntoConstraints = false
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: .alignAllCenterX, metrics: nil, views: ["view":screen])
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: .alignAllCenterX, metrics: nil, views: ["view":screen])
        self.addConstraints(h + v)

    }
    private func loadBottomBar(){
        self.addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: .alignAllCenterX, metrics: nil, views: ["view":bottomBar])
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:[view(64)]-0-|", options: .alignAllCenterX, metrics: nil, views: ["view":bottomBar])
        self.addConstraints(h + v)
    }
    private func loadCaptureBtn(){
        self.bottomBar.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let x = NSLayoutConstraint(item: self.bottomBar, attribute: .centerX, relatedBy: .equal, toItem: btn, attribute: .centerX, multiplier: 1, constant: 0)
        let y = NSLayoutConstraint(item: self.bottomBar, attribute: .centerY, relatedBy: .equal, toItem: btn, attribute: .centerY, multiplier: 1, constant: 0)
        self.bottomBar.addConstraints([x,y])
        btn.setImage(nomarlImage, for: .normal)
        btn.setImage(HighlightImage, for: .highlighted)
    }
    private lazy var nomarlImage:UIImage? = {
        return CameraView.drawBtn(color: UIColor.white, hightlight: false)
    }()
    private lazy var HighlightImage:UIImage? = {
        return CameraView.drawBtn(color: UIColor.white,hightlight:true)
    }()
    static func drawBtn(color:UIColor,hightlight:Bool)->UIImage?{
        UIGraphicsBeginImageContextWithOptions(CGSize(width:60,height:60), true, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: 60, height: 60).insetBy(dx: 4, dy: 4)
        ctx?.addEllipse(in: rect)
        
        ctx?.setFillColor(color.cgColor)
        if hightlight{
            ctx?.setShadow(offset: CGSize.zero, blur: 6, color: UIColor.white.cgColor)
        }
        ctx?.fillPath()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    func shutter(){
        camera?.GetImage(callback: { (i) in
            print(i)
            if let call = self.imageDelegate{
                call(i)
                
            }
        })
    }
}
