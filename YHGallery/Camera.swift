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
            self.videoDevice = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).filter({ (i) -> Bool in
                let dev = i as! AVCaptureDevice
                return dev.position == self.position
            })[0] as? AVCaptureDevice
            self.changeSessionSet {
                if let input = try? AVCaptureDeviceInput(device: self.videoDevice){
                    session.removeInput(self.videoInput)
                    self.videoInput = input
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
                self.videoDevice?.torchMode = self.torch
            }
        }
    }
    
    public var flash:AVCaptureFlashMode = .auto{
        didSet{
            self.changeDeviceSet {
                self.videoDevice?.flashMode = self.flash
            }
        }
        
    }
    
    public init?(){
        var req = false
        let status =  AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .authorized:
            config()
            configVideoInput()
            configAudio()
        default:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (i) in
                if i{
                    req = true
                    self.config()
                    self.configVideoInput()
                }
            })
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (i) in
                if i{
                    self.configAudio()
                    
                }
            })
            if !req{
                return
            }
        }
    }
    
    open func config(){
        
        
        output.setSampleBufferDelegate(self.Catch, queue: DispatchQueue.main)
        session.beginConfiguration()
        
        
        session.addOutput(output)
        session.addOutput(photo)
        session.commitConfiguration()
        
    }
    private func configVideoInput(){
        videoDevice = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).filter({ (i) -> Bool in
            let dev = i as! AVCaptureDevice
            return dev.position == self.position
        })[0] as? AVCaptureDevice
        session.beginConfiguration()
        videoInput = try? AVCaptureDeviceInput(device: videoDevice!)
        session.sessionPreset = self.preset
        session.addInput(videoInput)
        session.commitConfiguration()
    }
    private func configAudio(){
        audioDevice = AVCaptureDevice.devices(withMediaType: AVMediaTypeAudio)[0] as? AVCaptureDevice
        audioInput = try? AVCaptureDeviceInput(device: audioDevice!)
        session.beginConfiguration()
        session.addInput(audioInput!)
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
            try self.videoDevice?.lockForConfiguration()
            action()
            self.videoDevice?.unlockForConfiguration()
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
    private var videoDevice:AVCaptureDevice?
    private var audioDevice:AVCaptureDevice?
    private var videoInput:AVCaptureDeviceInput?
    private var audioInput:AVCaptureDeviceInput?
    private var output:AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    private var Catch = CatchImage()
    private var photo:AVCaptureStillImageOutput = AVCaptureStillImageOutput()
    
    
    public static func image(image:CIImage,filter:CIFilter?)->CIImage?{
        if let f = filter{
            f.setValue(image, forKey: "inputImage")
           
            return f.outputImage
        }else{
            return image
        }

    }
    
}
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
