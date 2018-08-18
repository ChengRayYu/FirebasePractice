//
//  WelcomeController.swift
//  FirebasePractice
//
//  Created by Ray on 07/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleSignIn

class WelcomeController: UIViewController {

    @IBOutlet weak var googleSignInBtn: UIButton!
    @IBOutlet weak var emailSignInBtn: UIButton!
    @IBOutlet weak var emailSignUpBtn: UIButton!

    fileprivate var emailAuthController: EmailAuthController?
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        rx()
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

    func rx() {

        let vm = WelcomeViewModel(withGoogleSignInOnTap: googleSignInBtn.rx.tap.asDriver())

        vm.googleSignedInDrv
            .drive()
            .disposed(by: disposeBag)

        vm.processingDrv
            .drive(onNext: { (flag) in
                flag ? self.showLoadingHud() : self.hideLoadingHud()
                self.googleSignInBtn.isEnabled = !flag
                self.emailSignInBtn.isEnabled = !flag
                self.emailSignUpBtn.isEnabled = !flag
            })
            .disposed(by: disposeBag)

        vm.errResponseDrv
            .flatMap({ (err) in
                self.showAlert(message: err).asDriver(onErrorDriveWith: Driver.never())
            })
            .drive()
            .disposed(by: disposeBag)

        emailSignInBtn.rx.tap
            .asObservable()
            .subscribe(onNext: { _ in
                self.performSegue(withIdentifier: "segue_welcome_emailAuth", sender: nil)
                guard let authCtrl = self.emailAuthController else { return }
                authCtrl.purpose = .signIn
            })
            .disposed(by: disposeBag)

        emailSignUpBtn.rx.tap
            .asObservable()
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

