//
//  mirror.swift
//  YHGallery
//
//  Created by hao yin on 2017/4/6.
//  Copyright © 2017年 hao yin. All rights reserved.
//

import CoreImage

public class MirrorFilter:CIFilter{
    private var kernel:CIWarpKernel!
    public override init(){
        let b = Bundle.init(for: MirrorFilter.self)
        super.init()
        guard let path = b.path(forResource: "mirror", ofType: "cikernel") else {
            return
        }
        do{
            let code = try String(contentsOfFile: path, encoding: .utf8)
            guard let c = CIKernel.kernels(with: code) else{
                return
            }
            kernel = c[0] as! CIWarpKernel
        }catch{
            return
        }
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public var inputImage:CIImage?
    public override var outputImage: CIImage?{
        return kernel.apply(withExtent: self.inputImage!.extent, roiCallback: { (_, rect) -> CGRect in
            return rect
        }, inputImage: inputImage!, arguments: [self.inputImage!.extent.width,self.inputImage!.extent.height])
    }
}
