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

    @IBOutlet weak var indi: TimeIndicate!
     
    override func viewDidLoad() {
        super.viewDidLoad()
        indi.data = [Date(),Date(),Date(),Date(),Date(),Date(),Date(),Date()]

    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.indi.index = 3
    }
    
}

