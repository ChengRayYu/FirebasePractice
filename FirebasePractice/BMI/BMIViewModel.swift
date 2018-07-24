//
//  BMIViewModel.swift
//  FirebasePractice
//
//  Created by Ray on 27/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseDatabase

class BMIViewModel {

    var loggedInDrv: Driver<Bool> = Driver.never()
    var recordsDrv: Driver<[BMIRecord]> = Driver.never()
    fileprivate var currentUserObs: Observable<User?> = Observable.never()

    init() {
        let currentUserObs = Auth.auth().rx
            .authStateChangeDidChange()
            .map({ (result) -> User? in
                return result.1
            })

        loggedInDrv = currentUserObs
            .map({ (user) -> Bool in
                if user != nil {
                    BMIService.initializeProfile()
                    return true
                }
                return false
            })
            .asDriver(onErrorJustReturn: false)
            .distinctUntilChanged()

        recordsDrv = currentUserObs
            .asDriver(onErrorJustReturn: nil)
            .flatMap({ _ -> Driver<[BMIService.Record]> in
                return BMIService.fetchBMIRecords()
            })
            .map({ (records) -> [BMIRecord] in
                if records.isEmpty {
                    return [BMIRecord.empty]
                }
                return records.map({ (serviceRecord) -> BMIRecord in
                    return BMIRecord.record(timestamp: serviceRecord.timestamp,
                                            height: serviceRecord.height,
                                            weight: serviceRecord.weight)
                })
            })
    }
}

// MARK: - Public Methods

extension BMIViewModel {

    func submitRecordOnTap(_ event: Observable<(height: Double, weight: Double)?>) -> Disposable {
        return event.subscribe(onNext: { (bmiInfo) in
            guard let bmi = bmiInfo else { return }
            BMIService.createBMIRecord(height: bmi.height, weight: bmi.weight)
        })
    }
}

enum BMIRecord {
    case record(timestamp: String, height: Double, weight: Double)
    case empty
}


