//
//  BMIRecordService.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/12.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseDatabase

class BMIRecordService {

    typealias Record = (timestamp: TimeInterval, height: Double, weight: Double)
    static let reference = Database.database().reference()

    static func setupProfile(ofUser uid: String, email: String) {
        let usersRef = reference.child("users")
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.hasChild(uid) {
                usersRef.child(uid).setValue(["email": email,
                                              "age": "",
                                              "gender": ""])
            }
        })
    }

    static func fetchBMIRecords(ofUser uid: String) -> Driver<[Record]> {
        return reference.child("records/\(uid)")
            .rx
            .observeEvent(.value)
            .map({ (snapshot) -> [Record] in
                return (1...4).map({ (index) -> Record in
                    return Record(Date().timeIntervalSinceNow, Double(arc4random_uniform(200) + 1), Double(arc4random_uniform(150) + 1))
                })
            })
            .asDriver(onErrorJustReturn: [])
    }

    static func addBMIRecord(forUser uid: String, height: Double, weight: Double) {

    }

}
