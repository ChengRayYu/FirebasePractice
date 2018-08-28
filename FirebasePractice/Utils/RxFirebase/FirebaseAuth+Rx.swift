//
//  RxFirebase.swift
//  FirebasePractice
//
//  Created by Ray on 11/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseAuth

extension Reactive where Base: Auth {

    func authStateDidChange() -> Observable<(Auth, User?)> {

        return Observable.create({ (observer: AnyObserver<(Auth, User?)>) -> Disposable in
            let listener = self.base.addStateDidChangeListener({ (auth, user) in
                observer.onNext((auth, user))
            })
            return Disposables.create(with: {
                self.base.removeStateDidChangeListener(listener)
            })
        })
    }

    func createUser(email: String, password: String) -> Observable<User?> {

        return Observable.create({ (observer: AnyObserver<(User?)>) -> Disposable in
            self.base.createUser(withEmail: email, password: password, completion: { (authResult, error) in
                if let err = error {
                    observer.onError(err)
                } else  {
                    observer.onNext(authResult?.user)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }

    func signIn(email: String, password: String) -> Observable<User?> {

        return Observable.create({ (observer: AnyObserver<(User?)>) -> Disposable in
            self.base.signIn(withEmail: email, password: password, completion: { (authResult, error) in
                if let err = error {
                    observer.onError(err)
                } else  {
                    observer.onNext(authResult?.user)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }

    func signIn(credential: AuthCredential) -> Observable<User?> {

        return Observable.create({ (observer: AnyObserver<(User?)>) -> Disposable in
            self.base.signInAndRetrieveData(with: credential, completion: { (authResult, error) in
                if let err = error {
                    observer.onError(err)
                } else  {
                    observer.onNext(authResult?.user)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }

    func signInForData(credential: AuthCredential) -> Observable<AuthDataResult?> {

        return Observable.create({ (observer: AnyObserver<AuthDataResult?>) -> Disposable in
            self.base.signInAndRetrieveData(with: credential) { (data, error) in
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

    func signOut() -> Observable<Void> {

        return Observable.create({ (observer: AnyObserver<Void>) -> Disposable in
            do {
                try self.base.signOut()
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        })
    }
}
