//
//  UserInfoViewModel.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/20.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class UserInfoViewModel {

    var userInfoDrv: Driver<BMIService.UserInfo?> = Driver.empty()
    var editingTypeDrv: Driver<UserInfoEditType?> = Driver.empty()

    init(withItemSelected itemOnSelect: Driver<IndexPath>) {

        userInfoDrv = BMIService.fetchUserInfo()

        editingTypeDrv = itemOnSelect
            .filter({ (index) -> Bool in
                return [2, 3, 4].contains(index.row)
            })
            .map({ (index) -> UserInfoEditType? in
                switch index.row {
                case 2:     return .username
                case 3:     return .gender
                case 4:     return .age
                default:    return nil
                }
            })
    }
}

extension UserInfoViewModel {

    func signOutOnTap(_ tap: Driver<Void>) -> Disposable {
        return tap.map({ _ in
            try! Auth.auth().signOut()
        })
        .drive()
    }
}

