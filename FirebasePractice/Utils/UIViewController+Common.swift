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

    func showAlert(title: String? = "Oops!", message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alertView, animated: true, completion: nil)
    }

    func showLoadingHud() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }

    func hideLoadingHud() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }

}
