//
//  AccountController.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/10.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class AccountController: UIViewController {

    @IBOutlet weak var signOutBtn: UIButton!

    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        signOutBtn.rx.tap.asObservable()
            .subscribe(onNext: { _ in
                do {
                    try Auth.auth().signOut()
                } catch {}
            })
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
