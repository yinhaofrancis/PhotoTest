//
//  rubbing.swift
//  YHGallery
//
//  Created by hao yin on 2017/4/6.
//  Copyright © 2017年 hao yin. All rights reserved.
//

import CoreImage
public class rubbing:CIFilter{
    private var colorKernel:CIColorKernel?
    public override init() {
        colorKernel = CIColorKernel.kernels(with: CIFilter.loadCode(name: "rubbing")!)![0] as? CIColorKernel
        super.init()
    }
    public override var outputImage: CIImage?{
        guard let img = self.inputImage else {
            return nil
        }
        return colorKernel?.apply(withExtent: img.extent, roiCallback: { (index, r) -> CGRect in
            return r
        }, arguments: [img,offset,threshold,color])
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public var offset:CGFloat = 1
    public var threshold = 1.15
    public var color:CIColor = CIColor(red: 0, green: 0, blue: 1, alpha: 1)
    public var inputImage:CIImage?
}
extension CIFilter{
    static func loadCode(name:String)->String?{
        let b = Bundle.init(for: rubbing.self)
        guard let path = b.path(forResource: name, ofType: "cikernel") else{
            return nil
        }
        guard let code = try? String.init(contentsOfFile: path) else {
            return nil
        }
        return code
    }
}
