//
//  CreateBMIViewModel.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/16.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class CreateBMIViewModel {

    let heightErrorDrv: Driver<String>
    let weightErrorDrv: Driver<String>
    let submissionDrv: Driver<Bool>
    let submissionErrDrv: Driver<String>
    let submitProgressDrv: Driver<Bool>

    init(input: (height: Driver<String>,
        weight: Driver<String>,
        confirm: Driver<Void>)) {

        let heightErrorSubject = PublishSubject<String>()
        heightErrorDrv = heightErrorSubject.asDriver(onErrorDriveWith: Driver.never())

        let validateHeight = input.confirm
            .withLatestFrom(input.height)
            .map { (content) -> Double? in
                guard !content.isEmpty else {
                    heightErrorSubject.onNext("Please specify how tall you are")
                    return nil
                }
                guard let height = Double(content) else {
                    heightErrorSubject.onNext("Invalid format")
                    return nil
                }
                heightErrorSubject.onNext("")
                return height
            }
            .asDriver()

        let weightErrorSubject = PublishSubject<String>()
        weightErrorDrv = weightErrorSubject.asDriver(onErrorDriveWith: Driver.never())

        let validateWeight = input.confirm
            .withLatestFrom(input.weight)
            .map { (content) -> Double? in
                guard !content.isEmpty else {
                    weightErrorSubject.onNext("Please specify how much you weigh")
                    return nil
                }
                guard let weight = Double(content) else {
                    weightErrorSubject.onNext("Invalid format")
                    return nil
                }
                weightErrorSubject.onNext("")
                return weight
            }
            .asDriver()

        let errSubject = PublishSubject<String>()
        submissionErrDrv = errSubject.asDriver(onErrorDriveWith: Driver.never())
        let activityIndicator = ActivityIndicator()
        submitProgressDrv = activityIndicator.asDriver()

        submissionDrv = Driver.combineLatest(validateHeight, validateWeight)
            .asObservable()
            .map({ (pair) -> (height: Double, weight: Double)? in
                guard let h = pair.0, let w = pair.1 else { return nil }
                return (h, w)
            })
            .skipWhile { $0 == nil }
            .flatMapLatest({ (entry) -> Observable<Bool> in
                errSubject.onNext("")
                guard let h = entry?.height, let w = entry?.weight else {
                    return Observable.never()
                }
                return BMIService.createRecord(height: h, weight: w)
                    .map({ (response) -> Bool in
                        switch response {
                        case .success:
                            return true
                        case .fail(let err):
                            errSubject.onNext(err.description)
                            return false
                        }
                    })
                    .trackActivity(activityIndicator)
            })
            .asDriver(onErrorJustReturn: false)
    }
}
