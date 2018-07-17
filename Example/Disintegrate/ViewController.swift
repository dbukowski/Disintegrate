// The MIT License
//
// Copyright (c) 2018 Dariusz Bukowski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Disintegrate

class ViewController: UIViewController {

    @IBOutlet weak var blackPantherImageView: UIImageView!
    @IBOutlet weak var scarletWitchImageView: UIImageView!
    @IBOutlet weak var draxImageView: UIImageView!
    @IBOutlet weak var starLordImageView: UIImageView!
    @IBOutlet weak var doctorStrangeImageView: UIImageView!
    @IBOutlet weak var spiderManImageView: UIImageView!
    
    @IBAction func snapButtonAction(_ sender: Any) {
        let fallenHeroImageViews = [self.blackPantherImageView,
                                    self.scarletWitchImageView,
                                    self.draxImageView,
                                    self.starLordImageView,
                                    self.doctorStrangeImageView,
                                    self.spiderManImageView]
        for (index, imageView) in fallenHeroImageViews.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(index * 2)) {
                imageView?.disintegrate()
            }
        }
    }

}

