//
//  UserInfoController.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/10.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserInfoController: UITableViewController {

    @IBOutlet weak var closeBarBtn: UIBarButtonItem!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var signOutBtn: UIButton!

    fileprivate var editController: UserInfoEditController?
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.backIndicatorImage = UIImage()
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_arrowLeft"), style: .plain, target: nil, action: nil)

        let viewModel = UserInfoViewModel(withItemSelected: tableView.rx.itemSelected.asDriver())

        viewModel.userInfoDrv
            .asObservable()
            .subscribe(onNext: { (userInfo) in
                guard let user = userInfo else { return }
                self.emailLbl.text = user.email
                self.usernameLbl.text = (user.name.isEmpty) ? "-" : user.name
                self.genderLbl.text = user.gender.description
                self.ageLbl.text = (user.age.intValue == -1) ? "–" : user.age.stringValue
            })
            .disposed(by: disposeBag)

        viewModel.editingTypeDrv
            .asObservable()
            .subscribe(onNext: { (editType) in
                guard let type = editType else { return }
                self.performSegue(withIdentifier: "segue_userInfo_startEdit", sender: nil)
                self.editController?.loadView()
                self.editController?.setupViewModel(ofEditingType: type)
            })
            .disposed(by: disposeBag)

        viewModel.signOutOnTap(signOutBtn.rx.tap.asDriver())
            .disposed(by: disposeBag)

        closeBarBtn.rx.tap
            .asObservable()
            .subscribe(onNext: { _ in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "segue_userInfo_startEdit":
            editController = segue.destination as? UserInfoEditController
        default:
            break
        }
    }
}

extension UserInfoController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
