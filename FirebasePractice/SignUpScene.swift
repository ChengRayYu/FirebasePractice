//
//  SignUpScene.swift
//  FirebasePractice
//
//  Created by Ray on 08/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SignUpScene: UIViewController {

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

extension SignUpScene {

    @IBAction func closeOnTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func googleSignInOnTap(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
   }
}

// MARK: -  GIDSignInDelegate

extension SignUpScene: GIDSignInDelegate {

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

extension SignUpScene: GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: false, completion: nil)
    }
}

