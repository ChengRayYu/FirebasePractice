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
import RxSwift
import RxCocoa

class WelcomeController: UIViewController {

    var emailAuthController: EmailAuthController?
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "segue_welcome_emailAuth":
            emailAuthController = segue.destination as? EmailAuthController
        default:
            break
        }
    }
}

// MARK: -  IBAction

extension WelcomeController {

    @IBAction func googleSignInBtnOnClick(_ sender: Any?) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()

        GIDSignIn.sharedInstance().rx.didSignIn
            .subscribe(onNext: { (input) in
                if let err = input.error {
                    print("GIDSingIn Failed")
                    print(err.localizedDescription)
                    return
                }
                let credential = GoogleAuthProvider.credential(withIDToken: input.user.authentication.idToken,
                                                               accessToken: input.user.authentication.accessToken)
                print(credential)
                print("""
                    GIDSingIn Succeed
                    idToken: \(input.user.authentication.idToken)
                    accessToken: \(input.user.authentication.accessToken)
                    """)
            }).disposed(by: disposeBag)
    }

    @IBAction func emailSignUpBtnOnClick(_ sender: Any) {
        performSegue(withIdentifier: "segue_welcome_emailAuth", sender: nil)
        guard let authCtrl = emailAuthController else { return }
        authCtrl.purpose = .signUp
    }

    @IBAction func emailSignInBtnOnClick(_ sender: Any) {
        performSegue(withIdentifier: "segue_welcome_emailAuth", sender: nil)
        guard let authCtrl = emailAuthController else { return }
        authCtrl.purpose = .signIn
    }
}

// MARK: -  GIDSignInDelegate

/*
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
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {

        print(#function)
        print(error)

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        print(credential)
    }
}
*/
// MARK: -  GIDSignInUIDelegate

extension WelcomeController: GIDSignInUIDelegate {

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: false, completion: nil)
    }
}
