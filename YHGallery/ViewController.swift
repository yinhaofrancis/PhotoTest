//
//  ViewController.swift
//  YHGallery
//
//  Created by hao yin on 2017/4/4.
//  Copyright © 2017年 hao yin. All rights reserved.
//

import UIKit
import GLKit
class ViewController: UIViewController {

     
    override func viewDidLoad() {
        super.viewDidLoad()
        self.glview.camera?.filer = CIFilter(name: "CIGaussianBlur")
        
    }
    var glview:CameraView{
        return self.view as! CameraView
    }
    
}

