//
//  BMIHeader.swift
//  FirebasePractice
//
//  Created by Ray on 29/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import RxSwift

class BMIHeader: UICollectionReusableView {
    @IBOutlet weak var createBtn: UIButton!
    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
