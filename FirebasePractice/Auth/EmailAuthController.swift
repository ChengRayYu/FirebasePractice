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

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var emailErrLbl: UILabel!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var passwordErrLbl: UILabel!
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
        titleLbl.text = viewModel?.pageTitle
        actionBtn.setTitle(viewModel?.functionTitle, for: .normal)
        rx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func rx() {

        guard let vm = viewModel else { return }

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
        
        vm.emailValidationDrv
            .drive(emailErrLbl.rx.text)
            .disposed(by: disposeBag)

        vm.passwordValidationDrv
            .drive(passwordErrLbl.rx.text)
            .disposed(by: disposeBag)

        vm.errorPublishDrv
            .flatMap({ (err) in
                self.showAlert(message: err).asDriver(onErrorDriveWith: Driver.never())
            })
            .drive()
            .disposed(by: disposeBag)

        vm.processingDrv
            .drive(onNext: { (flag) in
                flag ? self.showLoadingHud() : self.hideLoadingHud()
                if flag {
                    self.emailErrLbl.text = ""
                    self.passwordErrLbl.text = ""
                }
                self.emailTxtField.isEnabled = !flag
                self.passwordTxtField.isEnabled = !flag
                self.cancelBtn.isEnabled = !flag
                self.actionBtn.isEnabled = !flag
            })
            .disposed(by: disposeBag)

        vm.completionDrv
            .drive()
            .disposed(by: disposeBag)
    }
}
