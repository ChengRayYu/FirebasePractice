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
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var infoContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoContainerTrailingConstraint: NSLayoutConstraint!

    fileprivate static let SnapAnimationLength: TimeInterval = 0.2
    fileprivate var state: ControlState = .normal
    fileprivate var gestureOffsetAnchor: CGFloat?
    fileprivate var gestureOffset: CGFloat = 0
    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func controlState() -> Driver<ControlState> {
        return self.infoContainer.rx
            .anyGesture(
                .tap(),
                .pan(configuration: { gesture, delegate in
                    delegate.simultaneousRecognitionPolicy = .custom({ (gesture, otherGesture) -> Bool in
                        guard let scrollPan = otherGesture as? UIPanGestureRecognizer else { return true }
                        let velocity = scrollPan.velocity(in: self)
                        return fabs(velocity.y) > fabs(velocity.x)
                    })
                    delegate.beginPolicy = .custom({ gesture -> Bool in
                        guard let pan = gesture as? UIPanGestureRecognizer else { return true }
                        return fabs(pan.translation(in: pan.view).y) <= 0
                    })
                })
            )
            .map({ (gesture) -> (initial: CGFloat?, current: CGFloat?)? in
                guard let pan = gesture as? UIPanGestureRecognizer else { return nil }
                let location = pan.location(in: self)
                switch pan.state {
                case .began:    return (location.x, location.x)
                case .changed:  return (nil, location.x)
                case .ended:    return (nil, CGFloat.greatestFiniteMagnitude)
                default:        return nil
                }
            })
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

    var info: Binder<(timestamp: String, height: Double, weight: Double)> {
        return Binder(base, binding: { (cell, info) in
            
            cell.resultLbl.text = String(format: "%2.2f", info.weight / pow(info.height / 100, 2.0))
            cell.heightLbl.text = String(format: "%.2f", info.height / 100)
            cell.weightLbl.text = String(format: "%.0f", info.weight)

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM-dd-yyyy HH:mm"
            cell.dateLbl.text = formatter.string(from: Date(timeIntervalSince1970: (Double(info.timestamp) ?? 0) / 1000))
        })
    }
}

class BMIRecordCellViewModel {

    let infoDrv: Driver<(timestamp: String, height: Double, weight: Double)>
    let deletionSubject: PublishSubject<Void> = .init()
    let deletionDrv: Driver<String?>
    let deletionProgressDrv: Driver<Bool>

    init(stamp: String, h: Double, w: Double) {

        infoDrv = Driver.just((stamp, h, w))

        let activity = ActivityIndicator()
        deletionProgressDrv = activity.asDriver(onErrorDriveWith: Driver.never())

        deletionDrv = deletionSubject
            .flatMap({ _ -> Observable<String?> in
                return BMIService.deleteRecord(stamp)
                    .map({ (response) -> String? in
                        switch response {
                        case .success:
                            return nil
                        case .fail(let err):
                            return err.description
                        }
                    })
                    .trackActivity(activity)
            })
            .asDriver(onErrorJustReturn: nil)
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
