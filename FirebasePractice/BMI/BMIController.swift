//
//  BMIController.swift
//  FirebasePractice
//
//  Created by Ray on 09/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import FirebaseAuth

class BMIController: UIViewController {

    var welcomeController: WelcomeController?
    let gidAuthService = GIDAuthService.instance

    override func viewDidLoad() {
        super.viewDidLoad()

        print("\(gidAuthService)")

        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user != nil else {
                self.performSegue(withIdentifier: "segue_BMI_requestAuth", sender: nil)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "segue_BMI_requestAuth":
            welcomeController = segue.destination as? WelcomeController
            welcomeController?.viewModel = WelcomeViewModel(dependency: (gidAuth: gidAuthService, fbAuth: nil))

        default:
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - IBAction

extension BMIController {

    @IBAction func signOutBtnOnClick(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }catch {
            print(error)
        }
    }
}
