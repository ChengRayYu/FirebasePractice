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
import Kingfisher

class UserInfoViewModel {

    let userInfoDrv: Driver<BMIService.UserInfo?>
    let editingTypeDrv: Driver<BMIService.UserInfoEditType?>
    let userInfoErrDrv: Driver<String>
    let portraitDrv: Driver<URL?>
    let progressingDrv: Driver<Bool>
    let userSignedOut: Driver<Void>

    private static let optimizedPortraitSize = CGSize(width: 96.0, height: 96.0)

    init(input: (itemOnSelect: Driver<IndexPath>, portraitSelected: Driver<UIImage?>, signOutOnTap: Driver<Void>)) {

        let activityIndicator = ActivityIndicator()
        progressingDrv = activityIndicator.asDriver()
        let errSubject = PublishSubject<String>()
        userInfoErrDrv = errSubject.asDriver(onErrorDriveWith: Driver.never())

        userInfoDrv = BMIService.fetchUserInfo()
            .map({ (response) -> BMIService.UserInfo? in
                switch response {
                case .success(let resp):
                    return resp
                case .fail(let err):
                    errSubject.onNext(err.description)
                    return nil
                }
            })
            .trackActivity(activityIndicator)
            .asDriver(onErrorJustReturn: nil)

        editingTypeDrv = input.itemOnSelect
            .filter({ (index) -> Bool in
                return [1, 2, 3].contains(index.row)
            })
            .map({ (index) -> BMIService.UserInfoEditType? in
                switch index.row {
                case 1:     return .username
                case 2:     return .gender
                case 3:     return .age
                default:    return nil
                }
            })

        let portraitUploaded =  input.portraitSelected
            .flatMap({ (image) -> Driver<Void> in
                guard let portrait = image else {
                    return Driver.empty()
                }
                let optimizedPortrait = portrait.kf.resize(to: UserInfoViewModel.optimizedPortraitSize)
                return BMIService.updateUserPortrait(fromImage: optimizedPortrait)
                    .map({ (response) in
                        guard case .fail(let err) = response else { return }
                        errSubject.onNext(err.description)
                        return
                    })
                    .asDriver(onErrorJustReturn: ())
            })

        portraitDrv = Driver.of(userInfoDrv.map {_ in }, portraitUploaded).merge()
            .flatMap({ _ -> Driver<URL?> in
                return BMIService.fetchUserPortraitURL()
                    .map({ (response) -> URL? in
                        guard case .success(let resp) = response else { return nil }
                        return resp
                    })
                    .asDriver(onErrorJustReturn: nil)
            })
        
        userSignedOut = input.signOutOnTap
            .flatMap({ _ -> Driver<Void> in
                return BMIService.signOut()
                    .map({ (response) in
                        if case let .fail(err) = response {
                            errSubject.onNext(err.description)
                        }
                        return
                    })
                    .asDriver(onErrorJustReturn: ())
            })
    }
}
