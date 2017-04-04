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

    var camera = Camera()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gv = self.view as! GLKView
        gv.context = (camera?.context)!
        let f = CIFilter(name: "CIPhotoEffectChrome")
        camera?.view = self.view as? GLKView
        camera?.filer = f
        camera?.start(screenFrame: self.view.bounds)
        self.view.layer.contentsGravity = "resizeAspect"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        camera?.GetImage(callback: { (i) in
            self.camera?.stop()
            (segue.destination as! nViewController).img.image = i
        })
    }

}

