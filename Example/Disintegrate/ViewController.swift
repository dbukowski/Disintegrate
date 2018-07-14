//
//  ViewController.swift
//  Disintegrate
//
//  Created by dbukowski on 07/14/2018.
//  Copyright (c) 2018 dbukowski. All rights reserved.
//

import UIKit
import Disintegrate

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func snapButtonAction(_ sender: Any) {
        self.imageView.disintegrate()
    }

}

