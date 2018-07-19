//
//  CreateBMIController.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/16.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateBMIController: UIViewController {

    @IBOutlet weak var heightTxtField: UITextField!
    @IBOutlet weak var heightErrLabel: UILabel!
    @IBOutlet weak var weightTxtField: UITextField!
    @IBOutlet weak var weightErrLabel: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    fileprivate let disposeBag  = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Public Methods

extension CreateBMIController {

    func generateViewModel() -> CreateBMIViewModel {

        let viewModel = CreateBMIViewModel(input: (
            height: heightTxtField.rx.text.orEmpty.asDriver(),
            weight: weightTxtField.rx.text.orEmpty.asDriver(),
            confirm: confirmBtn.rx.tap.asDriver()))

        viewModel.heightErrorSubject
            .asObservable()
            .bind(to: heightErrLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.weightErrorSubject
            .asObservable()
            .bind(to: weightErrLabel.rx.text)
            .disposed(by: disposeBag)

        cancelBtn.rx.tap
            .asObservable()
            .subscribe(onNext: { _ in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        return viewModel
    }
}
