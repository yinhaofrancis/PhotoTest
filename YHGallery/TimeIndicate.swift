//
//  TimeIndicate.swift
//  YHGallery
//
//  Created by hao yin on 2017/4/7.
//  Copyright © 2017年 hao yin. All rights reserved.
//

import UIKit
public class CustomView:UIView{
    fileprivate lazy var isload:Bool = {
        return true
    }()
}
public class TimeAxis:CustomView {
    public init(){
        
        self.leftOffset = UIScreen.main.bounds.width / 2
        self.rightOffset = UIScreen.main.bounds.width / 2
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public var date:[Date] = []
    public var count:Int{
        return date.count
    }
    public var leftOffset:CGFloat
    public var rightOffset:CGFloat
    public var color:UIColor = UIColor.black
    public var width:CGFloat{
        return CGFloat(count - 1) * offsetWidth + self.leftOffset + rightOffset
    }
    
//  MARK:- can override
    open var offsetWidth:CGFloat = 96
    open var height:CGFloat = 40
    
// MARK:- override 
    
    public override func didMoveToWindow() {
        self.once { [unowned self] in
            self.frame.size = self.calcSize()
            self.isload = false
            self.backgroundColor = UIColor.white
        }
    }
    private func calcSize()->CGSize{
        return CGSize(width: self.width, height: height)
    }
    
    public override func draw(_ rect: CGRect) {
        self.date.sort()
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: leftOffset, y: rect.height * 3 / 4))
        context?.addLine(to: CGPoint(x: rect.width - rightOffset, y: rect.height * 3 / 4))
        context?.setStrokeColor(self.color.cgColor)
        context?.setLineWidth(1)
        context?.strokePath()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        var current:CGFloat = 0
        date.forEach { (d) in
            let string = format.string(from: d) as NSString
            let size = string.boundingRect(with: CGSize(width:320,height:320), options: [.truncatesLastVisibleLine,.usesDeviceMetrics], attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12)], context: nil)
            context?.move(to: CGPoint(x: leftOffset + current * self.offsetWidth, y: rect.height  / 2))
            context?.addLine(to:  CGPoint(x: leftOffset + current * self.offsetWidth, y: rect.height * 3 / 4))
            context?.strokePath()
            let textFrame = CGRect(x: leftOffset + current * self.offsetWidth - size.midX, y: 0, width: size.width, height: size.height)
            string.draw(in: textFrame, withAttributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12)])
            current += 1
        }
    }
}
public class TimeIndicate:CustomView{
    private var timeAxie:TimeAxis = TimeAxis()
    public override func didMoveToWindow() {
        self.once {
            self.addSubview(self.timeAxie)
            isload = false
        }
    }
}

extension NSObject {
    private var flag:Bool{
        get{
            let v = objc_getAssociatedObject(self, &association.flag) as? Bool
            return v ?? false
        }
        set{
            objc_setAssociatedObject(self, &association.flag, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    fileprivate struct association{
        static var flag:Bool = false
    }
    public func once(call:()->Void){
        if !flag{
            call()
            flag = true
        }
    }
}
