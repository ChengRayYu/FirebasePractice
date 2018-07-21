//
//  BMIService.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/12.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseDatabase

class BMIService {

    enum Gender: Int {
        case notAvailable = 0, male, female, neither

        var description: String {
            switch self {
            case .notAvailable:     return "–"
            case .male:             return "Male"
            case .female:           return "Female"
            case .neither:          return "Neither"
            }
        }
    }

    typealias UserInfo = (email: String, name: String, gender: Gender, age: NSNumber)
    typealias Record = (timestamp: String, height: Double, weight: Double)

    static func initializeProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let usersRef = Database.database().reference().child("users")

        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.hasChild(user.uid) {
                usersRef.child(user.uid).setValue(["email": user.email ?? "",
                                                   "displayName": user.displayName ?? "",
                                                   "age": "-1",
                                                   "gender": "-1"])
            }
        })
    }

    static func fetchUserInfo() -> Driver<UserInfo?> {

        guard let user = Auth.auth().currentUser else { return Driver.of(nil) }
        let userRef = Database.database().reference().child("users/\(user.uid)")

        return userRef.rx
            .observeEvent(.value)
            .map({ (snapshot) -> UserInfo? in
                let entries = snapshot.value as? [String: AnyObject]
                return (entries?["email"] as? String ?? "",
                        entries?["displayName"] as? String ?? "",
                        Gender(rawValue: ((entries?["gender"] as? NSNumber)?.intValue ?? 0)) ?? Gender.notAvailable,
                        entries?["age"] as? NSNumber ?? NSNumber(value: -1))
            })
            .asDriver(onErrorJustReturn: nil)
    }

    static func fetchBMIRecords() -> Driver<[Record]> {

        guard let user = Auth.auth().currentUser else { return Driver.from([]) }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM-dd-yyyy\tHH:mm"

        return Database.database().reference().child("records/\(user.uid)")
            .queryOrderedByKey()
            .rx
            .observeEvent(.value)
            .map({ (snapshot) -> [Record] in
                return snapshot.children.map({ (child) -> Record in
                    let childSnapshot = child as! DataSnapshot
                    let entries = childSnapshot.value as! [String: AnyObject]
                    return (formatter.string(from: Date(timeIntervalSince1970: (Double(childSnapshot.key) ?? 0) / 1000)),
                            entries["h"]?.doubleValue ?? 0,
                            entries["w"]?.doubleValue ?? 0)
                })
                .reversed()
            })
            .asDriver(onErrorJustReturn: [])
    }

    static func createBMIRecord(height: Double, weight: Double) {
        guard let user = Auth.auth().currentUser else { return }
        let userRecordRef = Database.database().reference().child("records/\(user.uid)")
        let timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        userRecordRef.child(timestamp).setValue(["h": NSNumber(value: height), "w": NSNumber(value: weight)])
    }
}
