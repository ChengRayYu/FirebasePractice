//
//  WelcomeController.swift
//  FirebasePractice
//
//  Created by Ray on 07/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class WelcomeController: UIViewController {

    @IBOutlet weak var googleSignInBtn: UIButton!
    @IBOutlet weak var fbSignInBtn: UIButton!
    @IBOutlet weak var emailSignInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "segue_emailSignIn":
            let vc = segue.destination as! SignInController
            vc.viewModel = SignInViewModel()
        default:
            break
        }
    }
}

// MARK: -  IBAction

extension WelcomeController {

    @IBAction func googleSignInBtnOnClick(_ sender: Any?) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
}

// MARK: -  GIDSignInDelegate

extension WelcomeController: GIDSignInDelegate {

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

        Auth.auth().signIn(with: credential) { (user, error) in

            if let error = error {
                print("Firebase Auth Failed")
                print(error.localizedDescription)
                return
            }
            print("""
                Firebase Auth Succeed
                user: \(user?.displayName ?? "name")
                email: \(user?.email ?? "email")
                """)
            self.performSegue(withIdentifier: "segue_BMI", sender: nil)
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        print(credential)
    }
}

// MARK: -  GIDSignInUIDelegate

extension WelcomeController: GIDSignInUIDelegate {

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: false, completion: nil)
    }
}

