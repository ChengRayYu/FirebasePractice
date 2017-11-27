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

    let signInProcessing: Driver<Bool>
    let googleSignedIn: Driver<User?>
    let googleSignInTap: PublishSubject<Void> = .init()

    private let activityIndicator: ActivityIndicator = .init()
    private let disposeBag: DisposeBag = .init()

    init(dependency: (
        gidAuth: GIDAuthService,
        fbAuth: AnyObject?)) {

        signInProcessing = activityIndicator.asDriver()

        googleSignInTap.subscribe(onNext: {
            GIDSignIn.sharedInstance().signIn()
        })
        .disposed(by: disposeBag)

        googleSignedIn = googleSignInTap
            .asDriver(onErrorJustReturn: ())
            .map { _ in
                GIDSignIn.sharedInstance().signIn()
            }
            .withLatestFrom(dependency.gidAuth.signed)
            .map({ (result) -> AuthCredential? in
                guard let res = result else { return nil }
                guard res.error == nil else { return nil }

                guard let authentication = res.user.authentication,
                    let idToken = authentication.idToken,
                    let accessToken = authentication.accessToken else {
                        return nil
                }
                return GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            })
            .flatMapLatest({ (credential) -> Driver<User?> in
                guard let cred = credential else { return Driver.empty()}
                return Auth.auth().rx_signIn(credential: cred)
                    .debug("[FIR]", trimOutput: false)
                    .asDriver(onErrorJustReturn: nil)
            })


            /*
            .flatMapLatest({ result -> Driver<User?> in

                guard let res = result else { return Driver<User?>.empty() }
                guard res.error == nil else { return Driver<User?>.empty() }

                guard let authentication = res.user.authentication,
                    let idToken = authentication.idToken,
                    let accessToken = authentication.accessToken else {
                        return Driver<User?>.empty()
                }
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                return Auth.auth().rx_signIn(credential: credential)
                    .debug("[FIR]", trimOutput: false)
                    //.trackActivity(self.activityIndicator)
                    .asDriver(onErrorJustReturn: nil)
            })
            */
            //.asDriver(onErrorJustReturn: nil)

    }

    /*
    func googleIDSignIn() -> Driver<User?> {

        return tap
            .map { _ in
                GIDSignIn.sharedInstance().signIn()
            }
            .flatMapLatest { _ in
                return GIDSignIn.sharedInstance().rx.didSignIn.asDriver(onErrorJustReturn: nil).debug("[GID]", trimOutput: false)
            }
            .flatMapLatest({ result -> Driver<User?> in

                guard let res = result else { return Driver<User?>.empty() }
                guard res.error == nil else { return Driver<User?>.empty() }

                guard let authentication = res.user.authentication,
                    let idToken = authentication.idToken,
                    let accessToken = authentication.accessToken else {
                        return Driver<User?>.empty()
                }
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                return Auth.auth().rx_signIn(credential: credential).share(replay: 1)
                    .debug("[FIR]", trimOutput: false)
                    .trackActivity(self.activityIndicator)
                    .asDriver(onErrorJustReturn: nil)
            })

    }
    */

    func googleIDDisconnected() -> Driver<GIDSignInResult?> {
        return GIDSignIn.sharedInstance().rx.didDisconnect
            .asDriver(onErrorJustReturn: nil)
    }
}
