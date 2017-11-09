//
//  SignUpStep1Controller.swift
//  FirebasePractice
//
//  Created by Ray on 08/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SignUpStep1Controller: UIViewController {

    // For both SignIn and SignUp
    // identidied by 2 different viewmodels

    @IBOutlet weak var accTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var googleSingInBtn: GIDSignInButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self

        googleSingInBtn.colorScheme = .dark
        googleSingInBtn.style = .wide
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: -  IBAction Events


// MARK: -  IBAction Events

extension WelcomeController {

    @IBAction func signUpOnTap(_ sender: Any) {
        performSegue(withIdentifier: "mainEntrance_signUp", sender: self)
    }
}



extension SignUpStep1Controller {

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

// MARK: -  GIDSignInDelegate

extension SignUpStep1Controller: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        if let error = error {
            print("GIDSingIn Failed")
            print(error.localizedDescription)
            return
        }

        guard let authentication = user.authentication else { return }

        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        print(credential)
        print("""
            GIDSingIn Succeed
            idToken: \(authentication.idToken)
            accessToken: \(authentication.accessToken)
            """)
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        print(credential)
    }
}

// MARK: -  GIDSignInUIDelegate

extension SignUpStep1Controller: GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: false, completion: nil)
    }
}

