//
//  ViewController.swift
//  Assignment4
//
//  Created by Tom Zhu on 2020-03-20.
//  Copyright © 2020 COMP1601. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
    }
    
    @IBAction func reset(_ sender: UIButton) {
        print(#function)
		(view as! DrawView).reset()
    }
}

