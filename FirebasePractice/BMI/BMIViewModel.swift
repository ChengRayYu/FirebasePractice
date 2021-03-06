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

enum BMIRecord {
    case record(viewModel: BMIRecordCellViewModel)
    case error(err: String)
    case empty
}

class BMIViewModel {

    let loggedInDrv: Driver<Bool>
    let profileInitStateDrv: Driver<Bool>
    let recordsDrv: Driver<[BMIRecord]>
    let newEntryEnabledDrv: Driver<Bool>
    let errResponseDrv: Driver<String>
    let reloadSubject: PublishSubject<Void> = .init()
    let reloadProgressDrv: Driver<Bool>

    init() {
        let errRespSubject = PublishSubject<String>()
        errResponseDrv = errRespSubject.asDriver(onErrorDriveWith: Driver.never())

        loggedInDrv = BMIService.authStateChanged()
            .map({ (response) -> User? in
                switch response {
                case .success(let resp):
                    return resp
                case .fail(let err):
                    errRespSubject.onNext(err.description)
                    return nil
                }
            })
            .map { $0 != nil }
            .asDriver(onErrorJustReturn: false)

        profileInitStateDrv = loggedInDrv
            .asObservable()
            .skipWhile { !$0 }
            .flatMap({ _ -> Observable<Bool> in
                return BMIService.initializeProfile()
                    .map({ (response) -> Bool in
                        switch response {
                        case .success:
                            return true
                        case .fail(let err):
                            errRespSubject.onNext(err.description)
                            return false
                        }
                    })
            })
            .asDriver(onErrorJustReturn: false)

        let loggedInAndReload = Driver.combineLatest(
            loggedInDrv,
            reloadSubject.startWith(())
                .asDriver(onErrorJustReturn: ())) {
                    (logged: $0, reload: $1 )
            }

        let reloadActIndicator = ActivityIndicator()
        reloadProgressDrv = reloadActIndicator.asDriver()
        
        recordsDrv = loggedInAndReload
            .asObservable()
            .flatMap({ _ -> Observable<[BMIRecord]> in

                return BMIService.fetchRecords()
                    .map({ (response) -> (records: [BMIService.Record]?, err: BMIService.Err?) in
                        switch response {
                        case .success(let resp):
                            return (resp, nil)
                        case .fail(let err):
                            return (nil, err)
                        }
                    })
                    .map({ (result) -> [BMIRecord] in
                        guard let records = result.records else {
                            return [BMIRecord.error(err: result.err?.description ?? "")]
                        }
                        if records.isEmpty {
                            return [BMIRecord.empty]
                        }
                        return records.map({ (serviceRecord) -> BMIRecord in
                            return BMIRecord.record(viewModel:
                                BMIRecordCellViewModel(stamp: serviceRecord.timestamp, h: serviceRecord.height, w: serviceRecord.weight)
                            )
                        })
                    })
                    .trackActivity(reloadActIndicator)
            })
            .asDriver(onErrorJustReturn: [])

        newEntryEnabledDrv = recordsDrv
            .map({ (records) -> Bool in
                guard records.count == 1, case .error = records[0] else {
                    return true
                }
                return false
            })
    }
}
