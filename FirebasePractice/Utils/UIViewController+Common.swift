//
//  UIViewController+Common.swift
//  FirebasePractice
//
//  Created by Ray on 2018/8/3.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import UIKit
import MBProgressHUD

extension UIViewController {

    func showAlert(title: String? = "Oops!", message: String, withCancelAction cancelBlock: (() -> Void)? = nil) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAct = UIAlertAction(title: "OK", style: .cancel) { (act) in
            if let act = cancelBlock {
                act()
            }
        }
        alertView.addAction(cancelAct)
        self.present(alertView, animated: true, completion: nil)
    }

    func showLoadingHud() {
        MBProgressHUD.showAdded(to: self.navigationController?.view ?? self.view, animated: true)
    }

    func hideLoadingHud() {
        MBProgressHUD.hide(for: self.navigationController?.view ?? self.view, animated: true)
    }

}
