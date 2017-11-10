//
//  SignUpController.swift
//  FirebasePractice
//
//  Created by Ray on 08/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpController: UIViewController {

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var emailErrLabel: UILabel!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var passwordErrLabel: UILabel!
    
    var viewModel: SignUpViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: -  Private Methods

extension SignUpController {

    fileprivate func hideKeybooard() {
        _ = emailTxtField.resignFirstResponder()
        _ = passwordTxtField.resignFirstResponder()
    }

    fileprivate func emailSignUp() {

        guard let email = emailTxtField.text, let pw = passwordTxtField.text else {
            emailErrLabel.text = (emailTxtField.text != nil) ? "" : "Please enter your email."
            passwordErrLabel.text = (passwordTxtField.text != nil) ? "" : "Please enter your password."
            return
        }

        self.emailErrLabel.text = ""
        self.passwordErrLabel.text = ""

        Auth.auth().createUser(withEmail: email, password: pw) { (user, err) in

            if let error = err {
                print("\(error._code)")

                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {

                    case .userDisabled, .emailAlreadyInUse, .invalidEmail:
                        self.emailErrLabel.text = error.localizedDescription

                    case .weakPassword:
                        self.passwordErrLabel.text = error.localizedDescription

                    default:
                        print("PROMPT ALERT : \(error.localizedDescription) ")
                    }
                }
                return
            }

            print("""
                Firebase Auth Succeed
                user: \(user?.displayName ?? "TBD")
                email: \(user?.email ?? "email")
                """)
        }
    }
}

// MARK: -  IBAction Events

extension SignUpController {

    @IBAction func backgroundOnTap(_ sender: UITapGestureRecognizer) {
        hideKeybooard()
    }

    @IBAction func cancelBtnOnTap(_ sender: Any) {
        dismiss(animated: true) {
            self.hideKeybooard()
        }
    }

    @IBAction func signUpOnTap(_ sender: Any) {
        emailSignUp()
    }
}
