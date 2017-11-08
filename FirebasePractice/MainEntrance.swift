//
//  MainEntrance.swift
//  FirebasePractice
//
//  Created by Ray on 07/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit

class MainEntrance: UIViewController {

    @IBOutlet weak var accTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: IBAction Events
    @IBAction func backgroundTap(_ sender: UITapGestureRecognizer) {
        print(#function)
        _ = accTxtField.resignFirstResponder()
        _ = passwordTxtField.resignFirstResponder()
    }


}

