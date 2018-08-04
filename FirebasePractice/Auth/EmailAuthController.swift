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
                                                    email: emailTxtField.rx.text.orEmpty.asDriver(),
                                                    password: passwordTxtField .rx.text.orEmpty.asDriver(),
                                                    actionTap: actionBtn.rx.tap.asDriver()))
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
        
        viewModel?.emailValidationDrv
            .drive(emailErrLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel?.passwordValidationDrv
            .drive(passwordErrLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel?.errorPublishDrv
            .drive(onNext: { (errStr) in
                self.showAlert(message: errStr)
            })
            .disposed(by: disposeBag)

        viewModel?.processingDrv
            .drive(onNext: { (flag) in
                flag ? self.showLoadingHud() : self.hideLoadingHud()
                if flag {
                    self.emailErrLabel.text = ""
                    self.passwordErrLabel.text = ""
                }
                self.emailTxtField.isEnabled = !flag
                self.passwordTxtField.isEnabled = !flag
                self.cancelBtn.isEnabled = !flag
                self.actionBtn.isEnabled = !flag
            })
            .disposed(by: disposeBag)

        viewModel?.completionDrv
            .drive(onNext: { (user) in
                print("""
                    Firebase Auth Complete
                    user: \(user?.displayName ?? "failed")
                    email: \(user?.email ?? "failed")
                    """)
            })
            .disposed(by: disposeBag)
    }
}
