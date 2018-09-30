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
    @IBOutlet weak var heightErrLbl: UILabel!
    @IBOutlet weak var weightTxtField: UITextField!
    @IBOutlet weak var weightErrLbl: UILabel!
    @IBOutlet weak var errLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var loadingBanner: UIView!

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

    func setupViewModel() {

        let vm = CreateBMIViewModel(input: (
            height: heightTxtField.rx.text.orEmpty.asDriver(),
            weight: weightTxtField.rx.text.orEmpty.asDriver(),
            confirm: confirmBtn.rx.tap.asDriver()))

        vm.submitProgressDrv
            .drive(onNext: { (flag) in
                self.heightTxtField.isEnabled = !flag
                self.weightTxtField.isEnabled = !flag
                self.cancelBtn.isEnabled = !flag
                self.confirmBtn.isHidden = flag
                self.loadingBanner.isHidden = !flag
            })
            .disposed(by: disposeBag)

        vm.submissionErrDrv
            .map({ (err) -> NSAttributedString? in
                guard !err.isEmpty else { return nil }
                let prefixAttr = [NSAttributedString.Key.foregroundColor: UIColor(named: "Grey800")!,
                                  NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 14.0)!]
                let lineAttr = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Regular", size: 6.0)!]
                let errorAttr = [NSAttributedString.Key.foregroundColor: UIColor(named: "Warning")!,
                                 NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 12.0)!]
                let prefix = NSMutableAttributedString(string: "Oops! Creating entry failed –\n", attributes: prefixAttr)
                let line = NSMutableAttributedString(string: "\n", attributes: lineAttr)
                let error = NSMutableAttributedString(string: err, attributes: errorAttr)

                let combination = NSMutableAttributedString()
                combination.append(prefix)
                combination.append(line)
                combination.append(error)
                return combination
            })
            .drive(errLbl.rx.attributedText)
            .disposed(by: disposeBag)

        vm.submissionDrv
            .drive(onNext: { (result) in
                if result {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)

        vm.heightErrorDrv
            .drive(heightErrLbl.rx.text)
            .disposed(by: disposeBag)

        vm.weightErrorDrv
            .drive(weightErrLbl.rx.text)
            .disposed(by: disposeBag)

        cancelBtn.rx.tap
            .asObservable()
            .subscribe(onNext: { _ in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
