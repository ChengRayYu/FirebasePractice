//
//  EmailAuthViewModel.swift
//  FirebasePractice
//
//  Created by Ray on 10/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import FirebaseAuth

protocol EmailAuthRes {
    var pageTitle: String { get }
    var functionTitle: String { get }
}

enum ValidationResult {
    case valid
    case empty
    case failed(message: String)
}

extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case .valid:
            return ""
        case .empty:
            return "Please enter something"
        case let .failed(message):
            return message
        }
    }
}

class EmailAuthViewModel: EmailAuthRes {

    enum Purpose { case signIn, signUp }

    var pageTitle: String { return "" }
    var functionTitle: String { return "" }

    let actionProcessing: Observable<Bool>
    var actionCompleted: Observable<User?>

    let emailValidation: Observable<ValidationResult>
    let passwordValidation: Observable<ValidationResult>
    let errorPublisher: Observable<String>

    fileprivate let errorResponse = PublishSubject<Error>()
    fileprivate let activityIndicator = ActivityIndicator()

    static func create(purpose: Purpose,
                       input: (
                            email: Observable<String>,
                            password: Observable<String>,
                            actionTap: Observable<Void>)) -> EmailAuthViewModel{

        switch purpose {
        case .signIn:   return SignInViewModel(input: input)
        case .signUp:   return SignUpViewModel(input: input)
        }
    }

    fileprivate init(input: (
        email: Observable<String>,
        password: Observable<String>,
        actionTap: Observable<Void>)) {

        actionCompleted = Observable.never()
        actionProcessing = activityIndicator.asObservable()

        errorPublisher = errorResponse.asObservable()
            .takeWhile({ (error) -> Bool in
                guard let errCode = AuthErrorCode(rawValue: error._code) else {
                    return true
                }
                let allowance: [AuthErrorCode] = [.userDisabled, .emailAlreadyInUse, .invalidEmail, .userNotFound, .weakPassword, .wrongPassword]
                guard allowance.contains(errCode) else {
                    return true
                }
                return false
            })
            .map({ (error) -> String in
                error.localizedDescription
            })

        let emailAndErr = Observable.combineLatest(input.email, errorResponse.asObservable()) { (email: $0, err: $1) }
        emailValidation = actionProcessing.withLatestFrom(emailAndErr, resultSelector: { (flag, content) -> ValidationResult in
            return ValidationService.validateEmail(content.email, authError: content.err)
        })

        let pwAndErr = Observable.combineLatest(input.password, errorResponse.asObservable()) { (passwd: $0, err: $1) }
        passwordValidation = actionProcessing.withLatestFrom(pwAndErr, resultSelector: { (flag, content) -> ValidationResult in
            return ValidationService.validatePassword(content.passwd, authError: content.err)
        })
    }
}

class ValidationService {

    static func validateEmail(_ email: String, authError err: Error) -> ValidationResult {
        if email.isEmpty {
            return .empty
        }

        if let errCode = AuthErrorCode(rawValue: err._code) {
            switch errCode {
            case .userDisabled, .emailAlreadyInUse, .invalidEmail, .userNotFound:
                return .failed(message: err.localizedDescription)
            default:
                break
            }
        }
        return .valid
    }

    static func validatePassword(_ password: String, authError err: Error) -> ValidationResult {
        if password.isEmpty {
            return .empty
        }

        if let errCode = AuthErrorCode(rawValue: err._code) {
            switch errCode {
            case .weakPassword, .wrongPassword:
                return .failed(message: err.localizedDescription)
            default:
                break
            }
        }
        return .valid
    }
}

class SignUpViewModel: EmailAuthViewModel {

    override var pageTitle: String { return "Sign Up for Healthy Life" }
    override var functionTitle: String { return "Sign Up" }

    fileprivate override init(input: (
        email: Observable<String>,
        password: Observable<String>,
        actionTap: Observable<Void>)) {

        super.init(input: input)

        let emailAndPw = Observable.combineLatest(input.email, input.password) { (email: $0, password: $1) }
        actionCompleted = input.actionTap.withLatestFrom(emailAndPw)
            .flatMap { (pair) in
                return Auth.auth().rx_createUser(email: pair.email, password: pair.password)
                    .catchError({ (err) -> Observable<(User?)> in
                        self.errorResponse.onNext(err)
                        return Observable.just(nil)
                    })
                    .trackActivity(self.activityIndicator)
                    .skipWhile{ $0 == nil }
            }
            .share(replay: 1, scope: .forever)
    }
}

class SignInViewModel: EmailAuthViewModel {

    override var pageTitle: String { return "Email Sign-In" }
    override var functionTitle: String { return "Sign In" }

    fileprivate override init(input: (
        email: Observable<String>,
        password: Observable<String>,
        actionTap: Observable<Void>)) {

        super.init(input: input)

        let emailAndPw = Observable.combineLatest(input.email, input.password) { (email: $0, password: $1) }
        actionCompleted = input.actionTap.withLatestFrom(emailAndPw)
            .flatMap { (pair) in
                return Auth.auth().rx_signIn(email: pair.email, password: pair.password)
                    .catchError({ (err) -> Observable<(User?)> in
                        self.errorResponse.onNext(err)
                        return Observable.just(nil)
                    })
                    .trackActivity(self.activityIndicator)
                    .skipWhile{ $0 == nil }
            }
            .share(replay: 1, scope: .forever)
    }
}
