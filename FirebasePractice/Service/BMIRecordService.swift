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

    typealias Record = (timestamp: String, height: Double, weight: Double)
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

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM-dd-yyyy\tHH:mm"

        return reference.child("records/\(uid)")
            .rx
            .observeEvent(.value)
            .map({ (snapshot) -> [Record] in
                return snapshot.children.map({ (child) -> Record in
                    let childSnapshot = child as! DataSnapshot
                    let entry = childSnapshot.value as! [String: AnyObject]

                    return (formatter.string(from: Date(timeIntervalSince1970: (Double(childSnapshot.key) ?? 0) / 1000)),
                            entry["h"]?.doubleValue ?? 0,
                            entry["w"]?.doubleValue ?? 0)
                })
            })
            .asDriver(onErrorJustReturn: [])
    }

    static func createBMIRecord(forUser uid: String, height: Double, weight: Double) {
        let userRecordRef = reference.child("records/\(uid)")
        let timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        userRecordRef.child(timestamp).setValue(["h": NSNumber(value: height), "w": NSNumber(value: weight)])
    }
}
