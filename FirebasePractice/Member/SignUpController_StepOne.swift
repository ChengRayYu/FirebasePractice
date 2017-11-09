//
//  SignUpController_StepOne.swift
//  FirebasePractice
//
//  Created by Ray on 08/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SignUpController_StepOne: UIViewController {

    @IBOutlet weak var accTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: -  IBAction Events

extension SignUpController_StepOne {

    @IBAction func backgroundOnTap(_ sender: UITapGestureRecognizer) {
        _ = accTxtField.resignFirstResponder()
        _ = passwordTxtField.resignFirstResponder()
    }

    @IBAction func closeOnTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func googleSignInOnTap(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
   }
}


