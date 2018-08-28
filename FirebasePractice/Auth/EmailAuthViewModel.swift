//
//  EmailAuthViewModel.swift
//  FirebasePractice
//
//  Created by Ray on 10/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

protocol EmailAuthRes {
    var pageTitle: String { get }
    var functionTitle: String { get }
}

class EmailAuthViewModel: EmailAuthRes {

    enum Purpose { case signIn, signUp }

    var pageTitle: String { return "" }
    var functionTitle: String { return "" }

    let processingDrv: Driver<Bool>
    var completionDrv: Driver<User?>

    let emailValidationDrv: Driver<String>
    let passwordValidationDrv: Driver<String>
    let errorPublishDrv: Driver<String>

    fileprivate let errorResponseSubject = PublishSubject<BMIService.Err>()
    fileprivate let activityIndicator = ActivityIndicator()

    static func create(purpose: Purpose,
                       input: (email: Driver<String>,  password: Driver<String>, actionTap: Driver<Void>)) -> EmailAuthViewModel {
        switch purpose {
        case .signIn:   return SignInViewModel(input: input)
        case .signUp:   return SignUpViewModel(input: input)
        }
    }

    fileprivate init(input: (
        email: Driver<String>,
        password: Driver<String>,
        actionTap: Driver<Void>)) {

        completionDrv = Driver.never()
        processingDrv = activityIndicator.asDriver()

        errorPublishDrv = errorResponseSubject.asObservable()
            .skipWhile { ValidationService.filterResponsedError($0) }
            .map { $0.description }
            .asDriver(onErrorDriveWith: Driver.never())

        let emailAndErr = Driver.combineLatest(input.email, errorResponseSubject.asDriver(onErrorDriveWith: Driver.never()))

        emailValidationDrv = processingDrv
            .withLatestFrom(emailAndErr)
            .map({ (pair) -> String in
                return ValidationService.checkEmail(pair.0, withResponsedError: pair.1)
            })

        let pwAndErr = Driver.combineLatest(input.password, errorResponseSubject.asDriver(onErrorDriveWith: Driver.never()))

        passwordValidationDrv = processingDrv
            .withLatestFrom(pwAndErr)
            .map({ (pair) -> String in
                return ValidationService.checkPassword(pair.0, withResponsedError: pair.1)
            })
    }

    fileprivate class ValidationService {

        static func checkEmail(_ email: String, withResponsedError err: BMIService.Err) -> String {
            guard !email.isEmpty else {
                return BMIService.Err.empty.description
            }
            guard case .auth(let code, let msg) = err else {
                return ""
            }
            switch code {
            case .userDisabled, .emailAlreadyInUse, .invalidEmail, .userNotFound:
                return msg
            default:
                return ""
            }
        }

        static func checkPassword(_ password: String, withResponsedError err: BMIService.Err) -> String {
            guard !password.isEmpty else {
                return BMIService.Err.empty.description
            }
            guard case .auth(let code, let msg) = err else {
                return ""
            }
            switch code {
            case .weakPassword, .wrongPassword:
                return msg
            default:
                return ""
            }
        }

        static func filterResponsedError(_ err: BMIService.Err) -> Bool {
            let codes: [AuthErrorCode] = [.userDisabled, .emailAlreadyInUse, .invalidEmail, .userNotFound, .weakPassword, .wrongPassword]
            guard case .auth(let code, _) = err, codes.contains(code) else {
                return false
            }
            return true
        }
    }
}

class SignUpViewModel: EmailAuthViewModel {

    override var pageTitle: String { return "Sign Up for Healthy Life" }
    override var functionTitle: String { return "Sign Up" }

    fileprivate override init(input: (
        email: Driver<String>,
        password: Driver<String>,
        actionTap: Driver<Void>)) {

        super.init(input: input)

        let emailAndPw = Driver.combineLatest(input.email, input.password) { (email: $0, password: $1) }
        completionDrv = input.actionTap.withLatestFrom(emailAndPw)
            .flatMap { (pair) in
                return BMIService.createUser(withEmail: pair.email, password: pair.password)
                    .map({ (response) -> User? in
                        switch response {
                        case .success(let resp):
                            return resp
                        case .fail(let err):
                            self.errorResponseSubject.onNext(err)
                            return nil
                        }
                    })
                    .trackActivity(self.activityIndicator)
                    .asDriver(onErrorJustReturn: nil)
            }
    }
}

class SignInViewModel: EmailAuthViewModel {

    override var pageTitle: String { return "Email Sign-In" }
    override var functionTitle: String { return "Sign In" }

    fileprivate override init(input: (
        email: Driver<String>,
        password: Driver<String>,
        actionTap: Driver<Void>)) {

        super.init(input: input)

        let emailAndPw = Driver.combineLatest(input.email, input.password) { (email: $0, password: $1) }

        completionDrv = input.actionTap.withLatestFrom(emailAndPw)
            .flatMap { (pair) in
                return BMIService.signIn(withEmail: pair.email, password: pair.password)
                    .map({ (response) -> User? in
                        switch response {
                        case .success(let resp):
                            return resp
                        case .fail(let err):
                            self.errorResponseSubject.onNext(err)
                            return nil
                        }
                    })
                    .trackActivity(self.activityIndicator)
                    .asDriver(onErrorJustReturn: nil)
            }
    }
}
