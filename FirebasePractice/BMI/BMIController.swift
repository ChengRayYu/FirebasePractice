//
//  BMIController.swift
//  FirebasePractice
//
//  Created by Ray on 09/11/2017.
//  Copyright © 2017 ycray.net. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture

class BMIController: UIViewController {

    @IBOutlet weak var bmiCollections: UICollectionView!
    fileprivate var bmiCollectionDataSrc: RxCollectionViewSectionedReloadDataSource<SectionModel<String, BMIRecord>>?
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        rx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "segue_BMI_createRecord":
            let vc = segue.destination as? CreateBMIController
            vc?.loadView()
            vc?.setupViewModel()

        default:
            return
        }
    }
}

extension BMIController {

    fileprivate func rx() {
        bmiCollections.rx.setDelegate(self).disposed(by: disposeBag)

        let vm = BMIViewModel()
        bmiCollectionDataSrc = RxCollectionViewSectionedReloadDataSource<SectionModel<String, BMIRecord>>(
            configureCell: { (dataSrc, cv, indexPath, item) -> UICollectionViewCell in
                switch dataSrc[indexPath] {
                case let .record(timestamp, height, weight):
                    let cell = cv.dequeueReusableCell(withReuseIdentifier: "BMIRecordCell", for: indexPath) as! BMIRecordCell
                    cell.resultLbl.text = String(format: "%2.2f", weight / pow(height / 100, 2.0))
                    cell.heightLbl.text = String(format: "%.2f", height / 100)
                    cell.weightLbl.text = String(format: "%.0f", weight)
                    cell.dateLbl.text = timestamp
                    cell.controlState(fromGestureLocation:
                        cell.infoContainer.rx
                            .anyGesture(
                                .tap(),
                                .pan(configuration: { gesture, delegate in
                                    delegate.simultaneousRecognitionPolicy = .custom({ (gesture, otherGesture) -> Bool in
                                        guard let scrollPan = otherGesture as? UIPanGestureRecognizer else { return true }
                                        let velocity = scrollPan.velocity(in: cell)
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
                                let location = pan.location(in: cell)
                                switch pan.state {
                                case .began:    return (location.x, location.x)
                                case .changed:  return (nil, location.x)
                                case .ended:    return (nil, CGFloat.greatestFiniteMagnitude)
                                default:        return nil
                                }
                            })
                        )
                        .drive(cell.rx.controlState)
                        .disposed(by: cell.disposeBag)

                    cell.deleteBtn.rx.tap
                        .asDriver()
                        .drive(vm.deleteSubject)
                        .disposed(by: cell.disposeBag)
                    vm.deleteProgressDrv
                        .drive()
                        .disposed(by: cell.disposeBag)
                    return cell

                case let .error(err):
                    let cell = cv.dequeueReusableCell(withReuseIdentifier: "BMIErrorCell", for: indexPath) as! BMIErrorCell
                    cell.errorLbl.text = err
                    cell.reloadBtn.rx.tap
                        .asDriver()
                        .drive(vm.reloadSubject)
                        .disposed(by: cell.disposeBag)
                    vm.reloadProgressDrv
                        .drive(cell.loadingIndicator.rx.isAnimating)
                        .disposed(by: cell.disposeBag)
                    vm.reloadProgressDrv
                        .drive(cell.reloadBtn.rx.isHidden)
                        .disposed(by: cell.disposeBag)
                    return cell

                case .empty:
                    return cv.dequeueReusableCell(withReuseIdentifier: "BMIEmptyMsgCell", for: indexPath)
                }
            },
            configureSupplementaryView: { (dataSrc, cv, kind, indexPath) -> UICollectionReusableView in
                (cv.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionHeadersPinToVisibleBounds = true
                switch kind {
                case UICollectionElementKindSectionHeader:
                    let header = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BMIHeader", for: indexPath) as! BMIHeader
                    vm.newEntryEnabledDrv
                        .drive(header.createBtn.rx.isEnabled)
                        .disposed(by: header.disposeBag)
                    return header
                default:
                    assert(false, "Unexpected element kind")
                }
            })

        vm.loggedInDrv
            .drive(onNext: { (flag) in
                self.dismiss(animated: true, completion: nil)
                if flag != true {
                    self.performSegue(withIdentifier: "segue_BMI_requestAuth", sender: nil)
                }
            })
            .disposed(by: disposeBag)

        vm.profileInitStateDrv
            .drive()
            .disposed(by: disposeBag)

        vm.errResponseDrv
            .drive(onNext: { (msg) in
                self.showAlert(message: msg)
            })
            .disposed(by: disposeBag)

        vm.recordsDrv
            .map({ (records) -> [SectionModel<String, BMIRecord>] in
                return [SectionModel(model: "", items: records)]
            })
            .drive(bmiCollections.rx.items(dataSource: bmiCollectionDataSrc!))
            .disposed(by: disposeBag)
    }
}

extension BMIController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let dataSrc = bmiCollectionDataSrc else { return CGSize.zero }

        switch dataSrc[indexPath] {
        case .record:
            return CGSize(width: collectionView.frame.size.width - 24.0, height: 92.0)
        default:
            return CGSize(width: collectionView.frame.size.width, height: 400.0)
        }
    }
}
