//
//  EmailAuthController.swift
//  FirebasePractice
//
//  Created by Ray on 08/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import FirebaseAuth

class EmailAuthController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var emailErrLabel: UILabel!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var passwordErrLabel: UILabel!
    @IBOutlet weak var actionBtn: UIButton!

    var viewModel: AnyObject?

    enum Purpose { case signIn, signUp }
    var purpose: Purpose? {
        willSet {
            guard let value = newValue else { return }
            switch value {
            case .signIn:   viewModel = SignInViewModel()
            case .signUp:   viewModel = SignUpViewModel()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let emailAuthRes = self.viewModel as! EmailAuthRes
        titleLabel.text = emailAuthRes.pageTitle
        actionBtn.setTitle(emailAuthRes.functionTitle, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: -  Private Methods

extension EmailAuthController {

    fileprivate func hideKeybooard() {
        _ = emailTxtField.resignFirstResponder()
        _ = passwordTxtField.resignFirstResponder()
    }

    fileprivate func emailSignIn() {

        guard let email = emailTxtField.text, let pw = passwordTxtField.text else {
            emailErrLabel.text = (emailTxtField.text != nil) ? "" : "Please enter your email."
            passwordErrLabel.text = (passwordTxtField.text != nil) ? "" : "Please enter your password."
            return
        }

        self.emailErrLabel.text = ""
        self.passwordErrLabel.text = ""

        Auth.auth().signIn(withEmail: email, password: pw) { (user, err) in

            if let error = err {
                self.promptError(error)
                return
            }
            print("""
                Firebase Auth Succeed
                user: \(user?.displayName ?? "TBD")
                email: \(user?.email ?? "email")
                """)
        }

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
                self.promptError(error)
                return
            }
            print("""
                Firebase Auth Succeed
                user: \(user?.displayName ?? "TBD")
                email: \(user?.email ?? "email")
                """)
        }
    }

    fileprivate func promptError(_ err: Error) {
        print("\(err._code)")

        if let errCode = AuthErrorCode(rawValue: err._code) {
            switch errCode {

            case .userDisabled, .emailAlreadyInUse, .invalidEmail, .userNotFound, .userDisabled:
                self.emailErrLabel.text = err.localizedDescription

            case .weakPassword, .wrongPassword:
                self.passwordErrLabel.text = err.localizedDescription

            default:
                print("PROMPT ALERT : \(err.localizedDescription) ")
            }
        }
    }
}

// MARK: -  IBAction Events

extension EmailAuthController {

    @IBAction func backgroundOnClick(_ sender: UITapGestureRecognizer) {
        hideKeybooard()
    }

    @IBAction func cancelBtnOnClick(_ sender: Any) {
        dismiss(animated: true) {
            self.hideKeybooard()
        }
    }

    @IBAction func actionBtnOnClick(_ sender: Any) {
        guard let p = purpose else { return }
        switch p {
        case .signIn:   emailSignIn()
        case .signUp:   emailSignUp()
        }
    }
}
