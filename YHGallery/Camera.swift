//
//  Camera.swift
//  YHGallery
//
//  Created by hao yin on 2017/4/4.
//  Copyright © 2017年 hao yin. All rights reserved.
//

import Foundation
import AVFoundation
import GLKit



typealias loadDevice = ()->Void
typealias getFrame = (CIImage)->Void

public class Camera{
    
    public var preset:String = AVCaptureSessionPresetPhoto{
        didSet{
            self.changeSessionSet {
                self.session.sessionPreset = preset
            }
        }
    }
    public var filer:CIFilter?{
        get{
            return self.Catch.filter
        }
        set{
            self.Catch.filter = newValue
        }
    }
    public var position:AVCaptureDevicePosition = .back{
        didSet{
            self.device = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).filter({ (i) -> Bool in
                let dev = i as! AVCaptureDevice
                return dev.position == self.position
            })[0] as? AVCaptureDevice
            self.changeSessionSet {
                if let input = try? AVCaptureDeviceInput(device: self.device){
                    session.removeInput(self.input)
                    self.input = input
                    session.addInput(input)
                }
            }
            
        }
    }
    public var witerBlance:AVCaptureWhiteBalanceMode{
        get{
            return self.witerBlance
        }
        set{
            self.changeDeviceSet {
                self.witerBlance = newValue
            }
        }
    }
    public var context:EAGLContext = EAGLContext(api: .openGLES2)
    
    public var torch:AVCaptureTorchMode = .auto{
        didSet{
            self.changeDeviceSet {
                self.device?.torchMode = self.torch
            }
        }
    }
    
    public var flash:AVCaptureFlashMode = .auto{
        didSet{
            self.changeDeviceSet {
                self.device?.flashMode = self.flash
            }
        }
    }
    
    public init?(){
        var req = false
        let status =  AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .authorized:
            config()
        default:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (i) in
                if i{
                    self.config()
                    req = true
                }
            })
            if !req{
                return
            }
        }
    }
    
    private func config(){
        device = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).filter({ (i) -> Bool in
            let dev = i as! AVCaptureDevice
            return dev.position == self.position
        })[0] as? AVCaptureDevice
        input = try? AVCaptureDeviceInput(device: device!)
        output.setSampleBufferDelegate(self.Catch, queue: DispatchQueue.main)
        session.beginConfiguration()
        session.sessionPreset = self.preset
        session.addInput(input)
        session.addOutput(output)
        session.addOutput(photo)
        session.commitConfiguration()
        
    }
    public func start(screenFrame:CGRect){
        let context = CIContext(eaglContext: self.context)
        Catch.output = {image in
            var frame = screenFrame
            frame.size.width = screenFrame.width * UIScreen.main.scale
            let height = screenFrame.height * UIScreen.main.scale
            frame.size.height = height
            let image = image.applying(CGAffineTransform(rotationAngle: -CGFloat.pi / 2))
            let b = image.extent.height / image.extent.width
            frame.size.height = frame.width * b
            if frame.size.height < height{
                let cha = height - frame.size.height
                frame.origin.y = cha / 2
                context.draw(image, in: frame, from: image.extent)
            }else{
                context.draw(image, in: frame, from: image.extent)
            }
            
            self.view?.display()
        }
        session.startRunning()
        
    }
    public func stop(){
        session.stopRunning()
    }
    public func changeSessionSet(action:()->Void){
        session.beginConfiguration()
        action()
        session.commitConfiguration()
    }
    public func changeDeviceSet(action:()->Void){
        do{
            try self.device?.lockForConfiguration()
            action()
            self.device?.unlockForConfiguration()
        }catch{
            
        }
    }
    
    public func GetImage(callback:@escaping (UIImage)->Void){
        let c = photo.connection(withMediaType: AVMediaTypeVideo)
        photo.captureStillImageAsynchronously(from: c, completionHandler: { (c, e) in
            if e == nil && c != nil{
                if let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(c!){
                    if let img = CIImage(data: data){
                        if let i = Camera.image(image: img.applying(CGAffineTransform(rotationAngle: CGFloat.pi / -2)), filter: self.filer){
                            callback(UIImage(cgImage: CIContext().createCGImage(i, from: i.extent)!, scale: UIScreen.main.scale, orientation: UIImageOrientation.up))
                        }
                        
                    }
                }
                
            }
        })

    }
    
    public weak var view:GLKView?

    private let session:AVCaptureSession = AVCaptureSession()
    private var device:AVCaptureDevice?
    private var input:AVCaptureDeviceInput?
    private var output:AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    private var Catch = CatchImage()
    private var photo:AVCaptureStillImageOutput = AVCaptureStillImageOutput()
    class CatchImage:NSObject,AVCaptureVideoDataOutputSampleBufferDelegate{
        func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
            if let sample = CMSampleBufferGetImageBuffer(sampleBuffer){
                let c = CIImage(cvImageBuffer: sample)
                if let img = Camera.image(image: c, filter: self.filter){
                    output?(img)
                }
            }
            
        }
        var output:getFrame?
        var filter:CIFilter?
    }
    private static func image(image:CIImage,filter:CIFilter?)->CIImage?{
        if let f = filter{
            f.setDefaults()
            f.setValue(image, forKey: "inputImage")
            return f.outputImage
        }else{
            return image
        }

    }
}
