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
    var recordsDrv: Driver<[BMIRecordService.Record]> = Driver.never()
    fileprivate var currentUserObs: Observable<User?> = Observable.never()

    init() {
        currentUserObs = Auth.auth().rx
            .authStateChangeDidChange()
            .map({ (result) -> User? in
                return result.1
            })

        loggedInDrv = currentUserObs
            .map({ (currentUser) -> Bool in
                guard let user = currentUser else { return false }
                BMIRecordService.setupProfile(ofUser: user.uid, email: user.email ?? "")
                return true
            })
            .asDriver(onErrorJustReturn: false)

        recordsDrv = currentUserObs
            .asDriver(onErrorJustReturn: nil)
            .flatMapLatest({ (user) -> Driver<[BMIRecordService.Record]> in
                guard let uid = user?.uid else { return Driver.from([])}
                return BMIRecordService.fetchBMIRecords(ofUser: uid)
            })
    }
}

// MARK: - Public Methods

extension BMIViewModel {

    func submitRecordOnTap(_ event: Observable<(height: Double, weight: Double)?>) -> Disposable {

        return event
            .withLatestFrom(currentUserObs, resultSelector: { (bmiInfo, user) -> (user: String, h: Double, w: Double)? in
                guard let uid = user?.uid, let bmi = bmiInfo  else { return nil }
                return (uid, bmi.height, bmi.weight)
            })
            .subscribe(onNext: { (result) in
                guard let res = result else { return }
                BMIRecordService.createBMIRecord(forUser: res.user, height: res.h, weight: res.w)
            })
    }
}

