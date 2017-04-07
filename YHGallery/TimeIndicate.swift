//
//  TimeIndicate.swift
//  YHGallery
//
//  Created by hao yin on 2017/4/7.
//  Copyright © 2017年 hao yin. All rights reserved.
//

import UIKit
public typealias indicateViewDelegate = (Int)->Void

public class TimeAxis:UIView {
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
        self.once(key:"key") { [unowned self] in
            self.frame.size = self.calcSize()
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
        format.dateFormat = "yyyy年MM月dd日"
        var current:CGFloat = 0
        date.forEach { (d) in
            let string = format.string(from: d) + "日" as NSString
            let size = string.boundingRect(with: CGSize(width:320,height:320), options: [.truncatesLastVisibleLine,.usesDeviceMetrics], attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize)], context: nil)
            context?.move(to: CGPoint(x: leftOffset + current * self.offsetWidth, y: rect.height  / 2))
            context?.addLine(to:  CGPoint(x: leftOffset + current * self.offsetWidth, y: rect.height * 3 / 4))
            context?.strokePath()
            let textFrame = CGRect(x: leftOffset + current * self.offsetWidth - size.midX, y: 0, width: size.width, height: size.height)
            string.draw(in: textFrame, withAttributes: [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize)])
            current += 1
        }
    }
    let fontSize:CGFloat = 10
}


public class TimeIndicate:UIScrollView,UIScrollViewDelegate{
    private var timeAxie:TimeAxis = TimeAxis()
    public var data:[Date]{
        set{
            self.timeAxie.date = newValue
            self.setNeedsDisplay()
        }
        get{
            return self.timeAxie.date
        }
    }
    public override func didMoveToWindow() {
        self.once(key: "key") {
            self.addSubview(self.timeAxie)
            self.showsHorizontalScrollIndicator = false
            self.delegate = self
            self.showsVerticalScrollIndicator = false
        }
    }
    public override func layoutSubviews() {
        self.timeAxie.frame.origin = CGPoint.zero
        self.timeAxie.height = self.frame.height
        self.contentSize = self.timeAxie.frame.size
    }
    public var index:Int{
        set{
            let rect = CGRect(origin: CGPoint(x: CGFloat(newValue) * self.timeAxie.offsetWidth, y: 0), size: self.frame.size)
            self.scrollRectToVisible(rect, animated: true)
        }
        get{
            return Int(round(contentOffset.x / timeAxie.offsetWidth))
        }
    }
    public var indicateDelegate:indicateViewDelegate?
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let rect = CGRect(origin: CGPoint(x: round(contentOffset.x / timeAxie.offsetWidth) * timeAxie.offsetWidth, y: 0), size: self.frame.size)
        self.scrollRectToVisible(rect, animated: true)
        indicateDelegate?(self.index)
    }
}

extension NSObject {
    private var flag:[String:Bool]{
        get{
            let v = objc_getAssociatedObject(self, &association.flag) as? [String:Bool]
            return v ?? [:]
        }
        set{
            objc_setAssociatedObject(self, &association.flag, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    fileprivate struct association{
        static var flag:[String:Bool] = [:]
    }
    public func once(key:String,call:()->Void){
        if flag[key] == nil{
            call()
            flag[key] = false
        }
    }
}
