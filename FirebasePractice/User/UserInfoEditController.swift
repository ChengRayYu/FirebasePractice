//
//  UserInfoEditController.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/20.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserInfoEditController: UIViewController {

    @IBOutlet weak var infoTypeLbl: UILabel!
    @IBOutlet weak var infoContentTxtField: UITextField!
    @IBOutlet weak var infoContentErrLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!

    fileprivate let optionPicker: UIPickerView = .init()
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        infoContentTxtField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Public Methods

extension UserInfoEditController {

    func setupViewModel(ofEditingType editType: BMIService.UserInfoEditType) {

        let viewModel = UserInfoEditViewModel(
            forType: editType,
            input: (infoContent: infoContentTxtField.rx.text.orEmpty.asDriver(),
                    saveOnTap: saveBtn.rx.tap.asDriver()))

        viewModel.editTypeDrv
            .map { $0.description }
            .drive(self.infoTypeLbl.rx.text)
            .disposed(by: disposeBag)

        viewModel.editTypeDrv
            .map { $0 == .username }
            .map({ (flag) -> (UITextFieldViewMode, UIColor) in
                return (flag ? .whileEditing : .never, flag ? UIColor(named: "Grey500")! : UIColor.clear)
            })
            .drive(onNext: { (result) in
                self.infoContentTxtField.clearButtonMode = result.0
                self.infoContentTxtField.tintColor = result.1
            })
            .disposed(by: disposeBag)

        viewModel.optionDrv
            .drive(optionPicker.rx.itemTitles) { (index, item) -> String in
                return "\(item)"
            }
            .disposed(by: disposeBag)

        viewModel.infoContentDrv
            .drive(onNext: { (result) in
                self.infoContentTxtField.text = result.content
                if let idx = result.optionIndex {
                    self.infoContentTxtField.inputView = self.optionPicker
                    self.optionPicker.selectRow(idx, inComponent: 0, animated: false)
                }
            })
            .disposed(by: disposeBag)

        optionPicker.rx.modelSelected(String.self)
            .asObservable()
            .map { $0[0] }
            .bind(to: self.infoContentTxtField.rx.text)
            .disposed(by: disposeBag)

    }
}
