//
//  SignUpScene.swift
//  FirebasePractice
//
//  Created by Ray on 08/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit

class SignUpScene: UIViewController {

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
}

// MARK: -  IBAction Events

extension SignUpScene {

    @IBAction func closeOnTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
