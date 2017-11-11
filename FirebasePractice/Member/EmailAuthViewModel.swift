//
//  EmailAuthViewModel.swift
//  FirebasePractice
//
//  Created by Ray on 10/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit

protocol EmailAuthRes {
    var pageTitle: String { get }
    var functionTitle: String { get }
    //func auth()
}

class SignUpViewModel: EmailAuthRes {

    var pageTitle: String { return "Sign Up for Healthy Life" }
    var functionTitle: String { return "Sign Up" }
}

class SignInViewModel: EmailAuthRes {

    var pageTitle: String { return "Email Sign-In" }
    var functionTitle: String { return "Sign In" }

}
