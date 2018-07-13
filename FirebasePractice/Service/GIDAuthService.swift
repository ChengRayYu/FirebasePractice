//
//  GIDAuthService.swift
//  FirebasePractice
//
//  Created by Ray on 24/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import GoogleSignIn

class GIDAuthService {

    static let instance: GIDAuthService = .init()

    private (set) var signed: Driver<GIDSignInResult?>
    //private (set) var disconnected: Driver<GIDSignInResult?>

    private init() {

        signed = Observable.deferred({ () -> Observable<GIDSignInResult?> in
            return GIDSignIn.sharedInstance()
                .rx.didSignIn.debug("[GID]", trimOutput: false)
        })
        .asDriver(onErrorJustReturn: nil)

    }
}
