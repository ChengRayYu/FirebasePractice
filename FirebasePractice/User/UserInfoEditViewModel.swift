//
//  UserInfoEditViewModel.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/20.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserInfoEditViewModel {

    var editTypeDrv: Driver<BMIService.UserInfoEditType> = Driver.never()
    var optionDrv : Driver<[String]> = Driver.never()
    var infoContentDrv : Driver<(content: String, optionIndex: Int?)> = Driver.never()
    var infoUpdatedDrv: Driver<Error> = Driver.never()
    var contentErrorSubject: PublishSubject<String?> = .init()

    init(forType type: BMIService.UserInfoEditType, input: (infoContent: Driver<String>, saveOnTap: Driver<Void>)) {

        editTypeDrv = Driver.just(type)

        optionDrv = editTypeDrv
            .filter { $0 != .username }
            .map({ (type) -> [String] in
                return type.options
            })

        infoContentDrv = BMIService.fetchUserInfo(ofType: type)
            .withLatestFrom(editTypeDrv, resultSelector: { (content, type) -> (content: String, optionIndex: Int?) in
                switch type {
                case .gender:
                    let gender = (content as? NSNumber) ?? -1
                    let options = type.options
                    let result = (gender == -1) ? options[0] : (BMIService.Gender(rawValue: gender.intValue)?.description ?? "")
                    return (result, options.index(of: result) ?? 0)

                case .age:
                    let age = (content as? NSNumber) ?? -1
                    let options = type.options
                    let result = (age == -1) ? options[0] : (BMIService.AgeRange(rawValue: age.intValue)?.description ?? "")
                    return (result, type.options.index(of: result) ?? 0)

                default:
                    return ((content as? String) ?? "", nil)
                }
            })
        
    }
}
