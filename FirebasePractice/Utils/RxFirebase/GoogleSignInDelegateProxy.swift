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

    var didSignIn: Observable<GIDSignInResult> {
        let proxy  = RxGoogleSignInDelegateProxy.proxy(for: base)
        return proxy.didSignInSubject
    }

    var didDisconnect: Observable<GIDSignInResult> {
        let proxy = RxGoogleSignInDelegateProxy.proxy(for: base)
        return proxy.didDisconnectSubject
    }
}

class RxGoogleSignInDelegateProxy
    : DelegateProxy<GIDSignIn, GIDSignInDelegate>
    , DelegateProxyType
    , GIDSignInDelegate {

    private(set) weak var googleSignIn: GIDSignIn?
    private var _didSignInSubject: PublishSubject<GIDSignInResult>?
    private var _didDisconnectSubject: PublishSubject<GIDSignInResult>?

    private init(googleSignIn: GIDSignIn) {
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

    fileprivate var didSignInSubject: PublishSubject<GIDSignInResult> {
        if let subject = _didSignInSubject {
            return subject
        }
        let subject = PublishSubject<GIDSignInResult>()
        _didSignInSubject = subject
        return subject
    }

    fileprivate var didDisconnectSubject: PublishSubject<GIDSignInResult> {
        if let subject = _didDisconnectSubject {
            return subject
        }
        let subject = PublishSubject<GIDSignInResult>()
        _didDisconnectSubject = subject
        return subject
    }


    func sign(_ signIn: GIDSignIn, didSignInFor user: GIDGoogleUser, withError error: Error?) {
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

        if let subject = _didSignInSubject {
            subject.on(.completed)
            subject.dispose()
        }

        if let subject = _didDisconnectSubject {
            subject.on(.completed)
            subject.dispose()
        }
    }
}
