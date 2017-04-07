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
        let a = TimeAxis()
        a.date = [Date(),Date(),Date(),Date(),Date(),Date(),Date(),Date(),Date(),Date(),Date(),Date(),Date()]
        self.view.addSubview(a)
        self.once {
            print("ok")
        }
        self.once {
            print("ok")
        }
    }
    
}

