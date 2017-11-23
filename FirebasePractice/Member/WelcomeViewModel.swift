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

    let signInProcessing: Observable<Bool>

    let errorPublisher: PublishSubject<String> = .init()
    private let activityIndicator: ActivityIndicator

    init() {
        activityIndicator = ActivityIndicator()
        signInProcessing = activityIndicator.asObservable()
    }

    func googleIDSignIn(tap: Observable<Void>) -> Observable<User?> {

        return tap
            .map { _ in
                GIDSignIn.sharedInstance().signIn()
            }
            .flatMapLatest { _ in
                return GIDSignIn.sharedInstance().rx.didSignIn
            }
            .flatMapLatest({ (result) -> Observable<User?> in
                if let err = result.error {
                    self.errorPublisher.onNext(err.localizedDescription)
                    return Observable.just(nil)
                }
                guard let authentication = result.user.authentication,
                    let idToken = authentication.idToken,
                    let accessToken = authentication.accessToken else {
                        self.errorPublisher.onNext("Invalid Google SignIn Authentication")
                        return Observable.just(nil)
                }
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                return Auth.auth().rx_signIn(credential: credential)
                    .trackActivity(self.activityIndicator)
            })
            .catchError({ (err) -> Observable<User?> in
                self.errorPublisher.onNext(err.localizedDescription)
                return Observable.just(nil)
            })
            .skipWhile{ $0 == nil }
            .share(replay: 1)
    }

    func googleIDDisconnected() -> Observable<GIDSignInResult> {
        return GIDSignIn.sharedInstance().rx.didDisconnect
    }
}
