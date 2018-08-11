//
//  BMICell.swift
//  FirebasePractice
//
//  Created by Ray on 28/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import RxSwift

class BMIRecordCell: UICollectionViewCell {
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var resultLbl: UILabel!
}

class BMIErrorCell: UICollectionViewCell {
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadBtn: UIButton!

    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
