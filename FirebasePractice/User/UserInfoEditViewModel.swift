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
    var infoContentDrv : Driver<(content: String?, optionIndex: Int?)> = Driver.never()
    var infoUpdatedDrv: Driver<Bool> = Driver.never()
    var contentErrorSubject: PublishSubject<String?> = .init()


    let disposeBag = DisposeBag()

    init(forType type: BMIService.UserInfoEditType, input: (infoContent: Driver<String>, selectedPickerIndex: Driver<Int>, saveOnTap: Driver<Void>)) {

        editTypeDrv = Driver.just(type)

        optionDrv = editTypeDrv
            .filter { $0 != .username }
            .map({ (type) -> [String] in
                return type.options
            })

        infoContentDrv = BMIService.fetchUserInfo(ofType: type)
            .withLatestFrom(editTypeDrv, resultSelector: { (content, type) -> (content: String?, optionIndex: Int?) in
                switch type {
                case .gender, .age:
                    let index = (content as? NSNumber) ?? -1
                    return (nil, index.intValue)
                default:
                    return ((content as? String) ?? "", nil)
                }
            })

        let typeAndInputs = Driver.combineLatest(editTypeDrv, input.infoContent, input.selectedPickerIndex)

        infoUpdatedDrv = input.saveOnTap
            .withLatestFrom(typeAndInputs, resultSelector: { (_, pair) -> (input: Any, type: BMIService.UserInfoEditType)? in
                switch pair.0 {
                case .username:
                    guard !pair.1.isEmpty else {
                        self.contentErrorSubject.onNext("Please enter something")
                        return nil
                    }
                    self.contentErrorSubject.onNext("")
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
            .map({ (pair) -> Bool in
                guard let pair = pair else { return false }
                BMIService.saveUserInfo(pair.input, ofType: pair.type)
                return true
            })
            .asDriver(onErrorJustReturn: false)
    }
}
