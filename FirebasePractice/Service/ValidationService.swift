//
//  ValidationService.swift
//  FirebasePractice
//
//  Created by Ray on 31/03/2018.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import UIKit
import FirebaseAuth

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

class ValidationService {

    static func validateEmail(_ email: String, authError err: Error) -> ValidationResult {
        if email.isEmpty {
            return .empty
        }
        guard let errCode = AuthErrorCode(rawValue: err._code) else { return .valid }
        switch errCode {
        case .userDisabled, .emailAlreadyInUse, .invalidEmail, .userNotFound:
            return .failed(message: err.localizedDescription)
        default:
            return .valid
        }
    }

    static func validatePassword(_ password: String, authError err: Error) -> ValidationResult {
        if password.isEmpty {
            return .empty
        }
        guard let errCode = AuthErrorCode(rawValue: err._code) else { return .valid }
        switch errCode {
        case .weakPassword, .wrongPassword:
            return .failed(message: err.localizedDescription)
        default:
            return .valid
        }
    }
}
