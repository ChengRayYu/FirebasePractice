//
//  WelcomeViewModel.swift
//  FirebasePractice
//
//  Created by Ray on 17/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth
import GoogleSignIn

class WelcomeViewModel {

    let processingDrv: Driver<Bool>
    let googleSignedInDrv: Driver<User?>
    let errResponseDrv: Driver<String>

    init(withGoogleSignInOnTap googleSignInOnTap: Driver<Void>) {

        let errRespSubject = PublishSubject<String>()
        let activityIndicator = ActivityIndicator()

        processingDrv = activityIndicator.asDriver()
        errResponseDrv = errRespSubject.asDriver(onErrorDriveWith: Driver.never())

        googleSignedInDrv = googleSignInOnTap
            .map {
                GIDSignIn.sharedInstance().signIn()
            }
            .flatMap({ () -> Driver<User?> in
                return BMIService.googleSignIn()
                    .map({ (response) -> User? in
                        switch response {
                        case .success(let resp):
                            return resp
                        case .fail(let err):
                            print(err)
                            let codes: [GIDSignInErrorCode] = [.canceled, .noSignInHandlersInstalled]
                            if case .gAuth(let code, _) = err, codes.contains(code) {
                                errRespSubject.onNext(err.description)
                            }
                            return nil
                        }
                    })
                    .trackActivity(activityIndicator)
                    .asDriver(onErrorJustReturn: nil)
            })
    }
}
