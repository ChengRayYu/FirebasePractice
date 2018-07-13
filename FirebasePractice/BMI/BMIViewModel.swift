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

class BMIViewModel: NSObject {

    var loggedInDrv: Driver<Bool> = Driver.never()
    var recordsDrv: Driver<[BMIRecordService.Record]> = Driver.never()
    private var createRecordPub: PublishSubject<(Double, Double)> = .init()

    override init() {

        let currentUserObs = Auth.auth().rx
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
            .flatMap({ (user) -> Driver<[BMIRecordService.Record]> in
                guard let uid = user?.uid else { return Driver.from([])}
                return BMIRecordService.fetchBMIRecords(ofUser: uid)
            })
    }
}
