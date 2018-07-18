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

    var submittedDrv: Driver<(height: Double, weight: Double)?> = Driver.empty()
    var heightErrorSubject: PublishSubject<String?> = .init()
    var weightErrorSubject: PublishSubject<String?> = .init()

    init(input: (height: Driver<String>,
        weight: Driver<String>,
        confirm: Driver<Void>)) {

        let validateHeight = input.confirm
            .withLatestFrom(input.height)
            .map { (content) -> Double? in
                guard !content.isEmpty else {
                    self.heightErrorSubject.onNext("Please specify how tall you are")
                    return nil
                }
                guard let height = Double(content) else {
                    self.heightErrorSubject.onNext("Invalid format")
                    return nil
                }
                self.heightErrorSubject.onNext("")
                return height
            }
            .asDriver()

        let validateWeight = input.confirm
            .withLatestFrom(input.weight)
            .map { (content) -> Double? in
                guard !content.isEmpty else {
                    self.weightErrorSubject.onNext("Please specify how much you weigh")
                    return nil
                }
                guard let weight = Double(content) else {
                    self.weightErrorSubject.onNext("Invalid format")
                    return nil
                }
                self.weightErrorSubject.onNext("")
                return weight
            }
            .asDriver()

        submittedDrv = Driver.combineLatest(validateHeight, validateWeight)
            .map({ (pair) -> (height: Double, weight: Double)? in
                guard let h = pair.0, let w = pair.1 else { return nil }
                return (h, w)
            })
    }
}
