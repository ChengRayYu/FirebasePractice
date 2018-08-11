//
//  BMIService+Enum.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/28.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import UIKit

extension BMIService {

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
