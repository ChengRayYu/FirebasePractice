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

    @IBOutlet weak var signOutBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user != nil else {
                self.performSegue(withIdentifier: "segue_BMI_requestAuth", sender: self)
                return
            }
            self.dismiss(animated: true, completion: nil)
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
            dismiss(animated: true, completion: nil)
        }catch {
            print(error)
        }
    }
}
