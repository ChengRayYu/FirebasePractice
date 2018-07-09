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

    @IBOutlet weak var googleSignInBtn: UIButton!
    @IBOutlet weak var emailSignInBtn: UIButton!
    @IBOutlet weak var emailSignUpBtn: UIButton!

    var emailAuthController: EmailAuthController?

    var viewModel: WelcomeViewModel?
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self

        bindViewModel()
        bindViewAction()
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

// MARK: - Private Methods
extension WelcomeController {

    func bindViewModel() {
        guard let vm = viewModel else { return }

        vm.googleSignedIn
            .drive(onNext: { (user) in
                print("USER: \(user?.displayName ?? "NULL")")
            })
            .disposed(by: disposeBag)
    }

    func bindViewAction() {
        guard let vm = viewModel else { return }

        googleSignInBtn.rx.tap
            .bind(to: vm.googleSignInTap)
            .disposed(by: disposeBag)

        emailSignInBtn.rx.tap.asObservable()
            .subscribe(onNext: { _ in
                 self.performSegue(withIdentifier: "segue_welcome_emailAuth", sender: nil)
                 guard let authCtrl = self.emailAuthController else { return }
                 authCtrl.purpose = .signIn
            })
            .disposed(by: disposeBag)

        emailSignUpBtn.rx.tap.asObservable()
            .subscribe(onNext: { _ in
                self.performSegue(withIdentifier: "segue_welcome_emailAuth", sender: nil)
                guard let authCtrl = self.emailAuthController else { return }
                authCtrl.purpose = .signUp
            })
            .disposed(by: disposeBag)
    }
}

extension WelcomeController: GIDSignInUIDelegate {

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated:  true, completion: nil)
    }
}

