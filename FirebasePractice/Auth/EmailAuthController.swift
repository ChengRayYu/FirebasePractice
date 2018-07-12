//
//  EmailAuthController.swift
//  FirebasePractice
//
//  Created by Ray on 08/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class EmailAuthController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var emailErrLabel: UILabel!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var passwordErrLabel: UILabel!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var backgroundTapGesture: UITapGestureRecognizer!

    fileprivate var viewModel: EmailAuthViewModel?
    fileprivate let disposeBag = DisposeBag()

    var purpose: EmailAuthViewModel.Purpose? {
        willSet {
            guard let value = newValue else { return }
            viewModel = EmailAuthViewModel.create(purpose: value,
                                                  input: (
                                                    email: emailTxtField.rx.text.orEmpty.asObservable(),
                                                    password: passwordTxtField .rx.text.orEmpty.asObservable(),
                                                    actionTap: actionBtn.rx.tap.asObservable()))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = viewModel?.pageTitle
        actionBtn.setTitle(viewModel?.functionTitle, for: .normal)
        rx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func rx() {
        cancelBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: {
                    self?.view.endEditing(true)
                })
            }).disposed(by: disposeBag)

        backgroundTapGesture.rx.event
            .subscribe(onNext: { (tap) in
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        viewModel?.emailValidation
            .map { $0.description }
            .bind(to: emailErrLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel?.passwordValidation
            .map { $0.description }
            .bind(to: passwordErrLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel?.errorPublisher
            .subscribe(onNext: { (errStr) in
                self.showAlert(message: errStr)
            })
            .disposed(by: disposeBag)

        viewModel?.actionProcessing
            .bind(onNext: { (flag) in
                if flag {
                    self.emailErrLabel.text = ""
                    self.passwordErrLabel.text = ""
                }
                self.emailTxtField.isEnabled = !flag
                self.passwordTxtField.isEnabled = !flag
                self.cancelBtn.isEnabled = !flag
                self.actionBtn.isEnabled = !flag
                print("ACTIVITY INDICATION IS - \((flag) ? "ON" : "OFF")")
            })
            .disposed(by: disposeBag)

        viewModel?.actionCompleted
            .subscribe(onNext: { (user) in
                print("""
                    Firebase Auth Succeed
                    user: \(user?.displayName ?? "TBD")
                    email: \(user?.email ?? "email")
                    """)
            })
            .disposed(by: disposeBag)
    }

    func showAlert(message: String) {
        let alertView = UIAlertController(title: "FirebasePractice", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alertView, animated: true, completion: nil)
    }
}
