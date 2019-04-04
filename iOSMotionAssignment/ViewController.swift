//
//  ViewController.swift
//  iOSTouch
//
//  Created by gliao on 2019-03-27.
//  Copyright © 2019 COMP1601. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
//        DrawView.onRotate()
    }


}

