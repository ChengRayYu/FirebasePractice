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
    @IBOutlet weak var loadingBanner: UIView!
    @IBOutlet weak var loadingBannerLbl: UILabel!
    @IBOutlet weak var loadingBannerSpinner: UIActivityIndicatorView!

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

extension UserInfoEditController: UIPickerViewDelegate {

    func startEditing(ofType editType: BMIService.UserInfoEditType) {

        let vm = UserInfoEditViewModel(
            forType: editType,
            input: (infoContent: infoContentTxtField.rx.text.orEmpty.asDriver(),
                    selectedPickerIndex: optionPicker.rx.itemSelected.asDriver().map { $0.row }.startWith(0),
                    saveOnTap: saveBtn.rx.tap.asDriver()))

        vm.editTypeDrv
            .map { $0.description }
            .drive(self.infoTypeLbl.rx.text)
            .disposed(by: disposeBag)

        vm.editTypeDrv
            .map { $0 == .username }
            .map({ (flag) -> (UITextFieldViewMode, UIColor) in
                return (flag ? .whileEditing : .never, flag ? UIColor(named: "Grey500")! : UIColor.clear)
            })
            .drive(onNext: { (result) in
                self.infoContentTxtField.clearButtonMode = result.0
                self.infoContentTxtField.tintColor = result.1
            })
            .disposed(by: disposeBag)

        vm.optionDrv
            .drive(optionPicker.rx.itemTitles) { (index, item) -> String in
                return "\(item)"
            }
            .disposed(by: disposeBag)

        vm.infoContentDrv
            .drive(onNext: { (result) in
                if let content = result.content {
                    self.infoContentTxtField.text = content
                }
                if let idx = result.optionIndex {
                    self.infoContentTxtField.inputView = self.optionPicker
                    self.optionPicker.selectRow(idx, inComponent: 0, animated: true)
                    self.optionPicker.delegate?.pickerView!(self.optionPicker, didSelectRow: idx, inComponent: 0)
                }
            })
            .disposed(by: disposeBag)

        optionPicker.rx.modelSelected(String.self)
            .asObservable()
            .map { $0[0] }
            .bind(to: self.infoContentTxtField.rx.text)
            .disposed(by: disposeBag)

        vm.infoUpdatedDrv
            .map({ (flag) -> Bool in
                self.loadingBannerLbl.text = "Saved!"
                return flag
            })
            .delay(0.6)
            .drive(onNext: { (flag) in
                if flag {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)

        vm.contentErrDrv
            .drive(infoContentErrLbl.rx.text)
            .disposed(by: disposeBag)

        vm.responseErrDrv
            .drive(onNext: { (err) in
                self.showAlert(message: err)
            })
            .disposed(by: disposeBag)

        vm.progressingDrv
            .drive(onNext: { (flag) in
                if flag {
                    self.loadingBanner.isHidden = false
                }
            })
            .disposed(by: disposeBag)

        vm.progressingDrv
            .drive(loadingBannerSpinner.rx.isAnimating)
            .disposed(by: disposeBag)

    }
}
