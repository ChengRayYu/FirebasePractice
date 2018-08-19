//
//  UIAlertController+Rx.swift
//  FirebasePractice
//
//  Created by Ray on 2018/8/17.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import UIKit
import RxSwift

extension UIAlertController {

    struct AlertAction {
        fileprivate let title: String?
        fileprivate let style: UIAlertActionStyle

        static func cancel(title: String?) -> AlertAction {
            return AlertAction(title: title, style: .cancel)
        }

        static func option(title: String?) -> AlertAction {
            return AlertAction(title: title, style: .default)
        }
    }

    static func present(in viewController: UIViewController,
                        title: String?,
                        message: String?,
                        style: UIAlertControllerStyle,
                        actions: [AlertAction]) -> Observable<Int> {

        return Observable.create { observer in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
            actions.enumerated().forEach({ (index, action) in
                let action = UIAlertAction(title: action.title, style: action.style) { _ in
                    observer.onNext(index)
                    observer.onCompleted()
                }
                alertController.addAction(action)
            })
            viewController.present(alertController, animated: true, completion: nil)
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
}
