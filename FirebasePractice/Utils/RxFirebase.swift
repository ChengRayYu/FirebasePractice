//
//  RxFirebase.swift
//  FirebasePractice
//
//  Created by Ray on 11/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import Foundation
import FirebaseAuth
import RxSwift

extension Auth {

    func rx_authStateChangeDidChange() -> Observable<(Auth, User?)> {

        return Observable.create({ (observer: AnyObserver<(Auth, User?)>) -> Disposable in

            let listener = self.addStateDidChangeListener({ (auth, user) in
                observer.onNext((auth, user))
            })
            return Disposables.create(with: {
                self.removeStateDidChangeListener(listener)
            })
        })
    }

    func rx_createUser(email: String, password: String) -> Observable<(User?)> {

        return Observable.create({ (observer: AnyObserver<(User?)>) -> Disposable in

            self.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let err = error {
                    observer.onError(err)
                } else {
                    observer.onNext(user)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }

    func rx_signIn(email: String, password: String) -> Observable<(User?)> {

        return Observable.create({ (observer: AnyObserver<(User?)>) -> Disposable in
            self.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let err = error {
                    observer.onError(err)
                } else {
                    observer.onNext(user)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }

    func rx_signIn(credential: AuthCredential) -> Observable<(User?)> {

        return Observable.create({ (observer: AnyObserver<(User?)>) -> Disposable in
            self.signIn(with: credential, completion: { (user, error) in
                if let err = error {
                    observer.onError(err)
                } else {
                    observer.onNext(user)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }

    func rx_signInForData(credential: AuthCredential) -> Observable<AuthDataResult?> {

        return Observable.create({ (observer: AnyObserver<AuthDataResult?>) -> Disposable in
            self.signInAndRetrieveData(with: credential) { (data, error) in
                if let err = error {
                    observer.onError(err)
                } else {
                    observer.onNext(data)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        })
    }

    func rx_signOut() -> Observable<Void> {
        return Observable.create({ (observer: AnyObserver<Void>) -> Disposable in
            do {
                try self.signOut()
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        })
    }
}
