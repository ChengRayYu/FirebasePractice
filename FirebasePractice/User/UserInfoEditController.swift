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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UserInfoEditController {

    func setupViewModel(ofEditingType type: UserInfoEditType) {

        let viewModel = UserInfoEditViewModel(forType: type)

        infoTypeLbl.text = type.rawValue
    }
}
