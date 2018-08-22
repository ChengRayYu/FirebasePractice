//
//  BMIService+Response.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/28.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseStorage

extension BMIService {

    enum Response<E> {
        case success(resp: E)
        case fail(err: Err)
    }

    enum Err: Error {
        case empty
        case unauthenticated
        case auth(code: AuthErrorCode, msg: String)
        case gAuth(code: GIDSignInErrorCode, msg: String)
        case storage(code: StorageErrorCode, msg: String)
        case service(msg: String)

        var description: String {
            switch self {
            case .empty:                return "Please enter something"
            case .unauthenticated:      return "Invalid user"
            case let .auth(_, msg):     return msg
            case let .gAuth(_, msg):    return msg
            case let .storage(_, msg):  return msg
            case let .service(msg):     return msg
            }
        }
    }
}
