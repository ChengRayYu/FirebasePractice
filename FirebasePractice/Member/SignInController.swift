//
//  SignInController.swift
//  FirebasePractice
//
//  Created by Ray on 09/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit

class SignInController: UIViewController {

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!

    var viewModel: SignInViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("\(viewModel?.sampleStr ?? "fff")")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}

// MARK: - IBAction Events

extension SignInController {

    @IBAction func backgroundOnClick(_ sender: UITapGestureRecognizer) {
        _ = emailTxtField.resignFirstResponder()
        _ = passwordTxtField.resignFirstResponder()
    }

    @IBAction func cancelOnClick(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
}
