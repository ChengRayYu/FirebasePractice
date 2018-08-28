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

    let editTypeDrv: Driver<BMIService.UserInfoEditType>
    let optionDrv : Driver<[String]>
    let infoContentDrv : Driver<(content: String?, optionIndex: Int?)>
    let infoUpdatedDrv: Driver<Bool>
    let contentErrDrv: Driver<String>
    let responseErrDrv: Driver<String>
    let progressingDrv: Driver<Bool>

    init(forType type: BMIService.UserInfoEditType, input: (infoContent: Driver<String>, selectedPickerIndex: Driver<Int>, saveOnTap: Driver<Void>)) {

        let activityIndicator = ActivityIndicator()
        progressingDrv = activityIndicator.asDriver()

        let contentErrSubject = PublishSubject<String>()
        contentErrDrv = contentErrSubject.asDriver(onErrorDriveWith: Driver.never())

        let respErrSubject = PublishSubject<String>()
        responseErrDrv = respErrSubject.asDriver(onErrorDriveWith: Driver.never())

        editTypeDrv = Driver.just(type)

        optionDrv = editTypeDrv
            .filter { $0 != .username }
            .map({ (type) -> [String] in
                return type.options
            })

        infoContentDrv = BMIService.fetchUserInfo(ofType: type)
            .withLatestFrom(editTypeDrv.asObservable(), resultSelector: { (response, type) -> (content: String?, optionIndex: Int?) in
                switch response {
                case .success(let resp):
                    switch type {
                    case .gender, .age:
                        return (nil, (resp as? NSNumber)?.intValue ?? -1)
                    default:
                        return ((resp as? String) ?? "", nil)
                    }
                case .fail(let err):
                    respErrSubject.onNext(err.description)
                    return (nil, nil)
                }
            })
            .asDriver(onErrorJustReturn: (nil, nil))

        let typeAndInputs = Driver.combineLatest(editTypeDrv, input.infoContent, input.selectedPickerIndex)

        infoUpdatedDrv = input.saveOnTap
            .withLatestFrom(typeAndInputs, resultSelector: { (_, pair) -> (input: Any, type: BMIService.UserInfoEditType)? in
                switch pair.0 {
                case .username:
                    guard !pair.1.isEmpty else {
                        contentErrSubject.onNext("Please enter something")
                        return nil
                    }
                    contentErrSubject.onNext("")
                    return (pair.1, type)
                case .gender, .age:
                    return ((pair.2 == 0) ? -1 : pair.2, type)
                default:
                    return nil
                }
            })
            .asObservable()
            .skipWhile({ (input) -> Bool in
                return input == nil
            })
            .flatMap({ (pair) -> Observable<Bool> in
                guard let p = pair else {
                    return Observable.never()
                }
                return BMIService.saveUserInfo(p.input, ofType: p.type)
                    .map({ (response) -> Bool in
                        switch response {
                        case .success:
                            return true
                        case .fail(let err):
                            respErrSubject.onNext(err.description)
                            return false
                        }
                    })
                    .trackActivity(activityIndicator)
            })
            .asDriver(onErrorJustReturn: false)
    }
}
