//
//  GoogleSignInDelegateProxy.swift
//  FirebasePractice
//
//  Created by Ray on 17/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import Foundation
import GoogleSignIn
import RxSwift
import RxCocoa

typealias GIDSignInResult = (user: GIDGoogleUser, error: Error?)

extension Reactive where Base: GIDSignIn {

    /*
    var signIn: ControlEvent<Void> {
        let source: Observable<Void> = Observable.create { observer in
            self.base.signIn()
            observer.on(.next(()))
            return Disposables.create()
            }
            .takeUntil(deallocated)

        return ControlEvent(events: source)
    }
    */
    
    var didSignIn: Observable<GIDSignInResult?> {
        let proxy  = RxGoogleSignInDelegateProxy.proxy(for: base)
        return proxy.didSignInSubject
    }

    var didDisconnect: Observable<GIDSignInResult?> {
        let proxy = RxGoogleSignInDelegateProxy.proxy(for: base)
        return proxy.didDisconnectSubject
    }
}

class RxGoogleSignInDelegateProxy
    : DelegateProxy<GIDSignIn, GIDSignInDelegate>
    , DelegateProxyType
    , GIDSignInDelegate {

    private(set) weak var googleSignIn: GIDSignIn?

    private init(googleSignIn: GIDSignIn) {
        print(#function)
        self.googleSignIn = googleSignIn
        super.init(parentObject: googleSignIn, delegateProxy: RxGoogleSignInDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { RxGoogleSignInDelegateProxy(googleSignIn: $0) }
    }

    static func currentDelegate(for object: GIDSignIn) -> GIDSignInDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: GIDSignInDelegate?, to object: GIDSignIn) {
        object.delegate = delegate
    }

    private var _didSignInSubject: PublishSubject<GIDSignInResult?>?
    private var _didDisconnectSubject: PublishSubject<GIDSignInResult?>?

    var didSignInSubject: PublishSubject<GIDSignInResult?> {
        if let subject = _didSignInSubject {
            return subject
        }
        let subject = PublishSubject<GIDSignInResult?>()
        _didSignInSubject = subject
        return subject
    }

    var didDisconnectSubject: PublishSubject<GIDSignInResult?> {
        if let subject = _didDisconnectSubject {
            return subject
        }
        let subject = PublishSubject<GIDSignInResult?>()
        _didDisconnectSubject = subject
        return subject
    }

    func sign(_ signIn: GIDSignIn, didSignInFor user: GIDGoogleUser, withError error: Error?) {
        print(#function)
        
        if let subject = _didSignInSubject {
            subject.on(.next((user: user, error: error)))
        }
        _forwardToDelegate?.sign(signIn, didSignInFor: user, withError: error)
    }

    func sign(_ signIn: GIDSignIn, didDisconnectWith user: GIDGoogleUser, withError error: Error) {
        if let subject = _didDisconnectSubject {
            subject.on(.next((user: user, error: error)))
        }
        _forwardToDelegate?.sign(signIn, didDisconnectWith: user, withError: error)
    }

    deinit {
        print(#function)
        _didSignInSubject?.on(.completed)
        _didDisconnectSubject?.on(.completed)
    }
}
