//
//  BMICell.swift
//  FirebasePractice
//
//  Created by Ray on 28/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BMIRecordCell: UICollectionViewCell {

    enum ControlState {
        case normal, transforming, delete

        fileprivate var snapPoint: CGFloat {
            switch self {
            case .normal:   return 0.0
            case .delete:   return 80.0
            default:        return CGFloat.leastNormalMagnitude
            }
        }

        fileprivate var offsetThreshold: CGFloat {
            switch self {
            case .transforming: return 20.0
            case .delete:       return 72.0
            default:            return CGFloat.leastNormalMagnitude
            }
        }
    }

    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var infoContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoContainerTrailingConstraint: NSLayoutConstraint!

    fileprivate static let SnapAnimationLength: TimeInterval = 0.3
    var state: ControlState = .normal
    fileprivate var gestureOffsetAnchor: CGFloat?
    fileprivate var gestureOffset: CGFloat = 0
    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func controlState(fromGestureLocation gestureObs: Observable<(initial: CGFloat?, current: CGFloat?)?>) -> Driver<ControlState> {
        return gestureObs
            .map { (gestureLocation) -> ControlState in
                guard let location = gestureLocation else {
                    return .normal
                }
                if let anchor =  location.initial {
                    self.gestureOffsetAnchor = (self.state == .delete) ?
                        (anchor + BMIRecordCell.ControlState.transforming.offsetThreshold + self.state.snapPoint) : anchor
                }
                guard let anchor = self.gestureOffsetAnchor, let current = location.current else {
                    return .normal
                }
                guard current != CGFloat.greatestFiniteMagnitude else {
                    if self.gestureOffset > ControlState.delete.offsetThreshold {
                        return .delete
                    }
                    return .normal
                }

                self.gestureOffset = (anchor - current)
                print(self.gestureOffset)
                if self.gestureOffset > ControlState.transforming.offsetThreshold {
                    self.infoContainerLeadingConstraint.constant = -self.gestureOffset + ControlState.transforming.offsetThreshold
                    self.infoContainerTrailingConstraint.constant = self.gestureOffset - ControlState.transforming.offsetThreshold
                    return .transforming
                }
                return .normal
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .normal)
    }
}

extension Reactive where Base: BMIRecordCell {

    var controlState: Binder<BMIRecordCell.ControlState> {
        return Binder(base, binding: { (cell, newState) in
            cell.state = newState
            guard cell.state != .transforming else { return }

            let gap = BMIRecordCell.ControlState.transforming.offsetThreshold
            let durationRatio = (cell.gestureOffset > BMIRecordCell.ControlState.delete.offsetThreshold) ?
                fabs(cell.gestureOffset - gap - BMIRecordCell.ControlState.delete.snapPoint) / BMIRecordCell.ControlState.delete.snapPoint :
                fabs(cell.gestureOffset - gap) / BMIRecordCell.ControlState.delete.snapPoint
            let duration = BMIRecordCell.SnapAnimationLength * Double(min(durationRatio, 1.0))

            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                cell.infoContainerLeadingConstraint.constant = -newState.snapPoint
                cell.infoContainerTrailingConstraint.constant = newState.snapPoint
                cell.layoutIfNeeded()
            })
        })
    }
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
