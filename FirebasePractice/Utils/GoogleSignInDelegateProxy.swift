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
        let proxy = RxGoogleSignInDelegateProxy.proxy(for: base)
        return proxy.didSignInSubject.asObservable()
    }
}

class RxGoogleSignInDelegateProxy
    : DelegateProxy<GIDSignIn, GIDSignInDelegate>
    , DelegateProxyType
    , GIDSignInDelegate {

    private(set) weak var googleSignIn: GIDSignIn?

    private init(googleSignIn: GIDSignIn) {
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


    lazy var didSignInSubject = PublishSubject<GIDSignInResult>()
    lazy var didDisconnectSubject = PublishSubject<GIDSignInResult>()

    func sign(_ signIn: GIDSignIn, didSignInFor user: GIDGoogleUser, withError error: Error?) {
        didSignInSubject.onNext((user: user, error: error))
        _forwardToDelegate?.sign(signIn, didSignInFor: user, withError: error)
    }

    func sign(_ signIn: GIDSignIn, didDisconnectWith user: GIDGoogleUser, withError error: Error) {
        didDisconnectSubject.onNext((user: user, error: error))
        _forwardToDelegate?.sign(signIn, didDisconnectWith: user, withError: error)
    }

    deinit {
        self.didSignInSubject.on(.completed)
        self.didDisconnectSubject.on(.completed)
    }
}

class RxGoogleSignInUIDelegateProxy
    : DelegateProxy<GIDSignIn, GIDSignInUIDelegate>
    , DelegateProxyType
    , GIDSignInUIDelegate {

    private init(googleSignIn: GIDSignIn) {
        super.init(parentObject: googleSignIn, delegateProxy: RxGoogleSignInUIDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { RxGoogleSignInUIDelegateProxy(googleSignIn: $0) }
    }

    static func currentDelegate(for object: GIDSignIn) -> GIDSignInUIDelegate? {
        return object.uiDelegate
    }

    static func setCurrentDelegate(_ delegate: GIDSignInUIDelegate?, to object: GIDSignIn) {
        object.uiDelegate = delegate
    }

    lazy var signInPresent = PublishSubject<UIViewController>()
    lazy var signInDismiss = PublishSubject<UIViewController>()

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        signInPresent.onNext(viewController)
        _forwardToDelegate?.sign(signIn, present: viewController)
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        signInDismiss.onNext(viewController)
        _forwardToDelegate?.sign(signIn, dismiss: viewController)
    }

    deinit {
        self.signInPresent.on(.completed)
        self.signInDismiss.on(.completed)
    }
}
