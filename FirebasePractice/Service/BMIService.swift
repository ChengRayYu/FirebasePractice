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

        case notAvailable = -1
        case male = 1
        case female = 2
        case neither = 3

        var description: String {
            switch self {
            case .notAvailable:     return "–"
            case .male:             return "Male"
            case .female:           return "Female"
            case .neither:          return "Neither"
            }
        }
    }

    enum AgeRange: Int {

        case notAvailable = -1
        case underTen = 1
        case tenToTwenty = 2
        case twentyOneToThirty = 3
        case thirtyOneToForty = 4
        case fortyOneToFifty = 5
        case overFifty = 6

        var description: String {
            switch self {
            case .notAvailable:         return "–"
            case .underTen:             return "Under 10"
            case .tenToTwenty:          return "10 - 20"
            case .twentyOneToThirty:    return "21 - 30"
            case .thirtyOneToForty:     return "31 - 40"
            case .fortyOneToFifty:      return "41 - 50"
            case .overFifty:            return "Over 50"
            }
        }
    }

    enum UserInfoEditType: String {

        case email = "email"
        case username = "displayName"
        case gender = "gender"
        case age = "age"

        var description : String {
            switch self {
            case .email:    return "Email"
            case .username: return "Username"
            case .gender:   return "Gender"
            case .age:      return "Age"
            }
        }

        var options: [String] {
            switch self {
            case .gender:
                return ["–",
                        Gender.male.description,
                        Gender.female.description,
                        Gender.neither.description]
            case .age:
                return ["–",
                        AgeRange.underTen.description,
                        AgeRange.tenToTwenty.description,
                        AgeRange.twentyOneToThirty.description,
                        AgeRange.thirtyOneToForty.description,
                        AgeRange.fortyOneToFifty.description,
                        AgeRange.overFifty.description]
            default:
                return []
            }
        }
    }

    typealias UserInfo = (email: String, name: String, gender: Gender, age: AgeRange)
    typealias Record = (timestamp: String, height: Double, weight: Double)
}

// MARK: - BMI UserInfo Operations

extension BMIService {

    static func initializeProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let usersRef = Database.database().reference().child("users")

        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.hasChild(user.uid) {
                usersRef.child(user.uid).setValue([UserInfoEditType.email.rawValue: user.email ?? "",
                                                   UserInfoEditType.username.rawValue: user.displayName ?? "",
                                                   UserInfoEditType.gender.rawValue: -1,
                                                   UserInfoEditType.age.rawValue: -1])
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
                return (entries?[UserInfoEditType.email.rawValue] as? String ?? "",
                        entries?[UserInfoEditType.username.rawValue] as? String ?? "",
                        Gender(rawValue: ((entries?[UserInfoEditType.gender.rawValue] as? NSNumber)?.intValue ?? -1)) ?? Gender.notAvailable,
                        AgeRange(rawValue: ((entries?[UserInfoEditType.age.rawValue] as? NSNumber)?.intValue ?? -1)) ?? AgeRange.notAvailable)
            })
            .asDriver(onErrorJustReturn: nil)
    }

    static func fetchUserInfo(ofType type: UserInfoEditType) -> Driver<Any?> {

        guard let user = Auth.auth().currentUser else { return Driver.of(nil) }
        let userInfoRef = Database.database().reference().child("users/\(user.uid)/\(type.rawValue)")

        return userInfoRef.rx
            .observeSingleEvent(.value)
            .map { (snapshot) -> Any? in
                return snapshot.value
            }
            .asDriver(onErrorJustReturn: nil)
    }

    static func saveUserInfo(_ content: Any, ofType type: UserInfoEditType) {
        guard let user = Auth.auth().currentUser else { return }
        let contentRef = Database.database().reference().child("users/\(user.uid)/\(type.rawValue)")
        contentRef.setValue(content)
    }
}


// MARK: - BMI Record Operations

extension BMIService {

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
