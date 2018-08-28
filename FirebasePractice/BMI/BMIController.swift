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
                case .record(let recordVM):
                    let cell = cv.dequeueReusableCell(withReuseIdentifier: "BMIRecordCell", for: indexPath) as! BMIRecordCell
                    recordVM.infoDrv
                        .drive(cell.rx.info)
                        .disposed(by: cell.disposeBag)
                    cell.controlState()
                        .drive(cell.rx.controlState)
                        .disposed(by: cell.disposeBag)
                    cell.deleteBtn.rx.tap
                        .flatMap({ _ -> Observable<Int> in
                            return self.showAlert(title: "Delete Record?",
                                                  message: "Confirm to delete this entry? ",
                                                  actions: [.cancel(title: "Cancel"), .option(title: "Delete")])
                        })
                        .skipWhile { $0 == 0 }
                        .map { _ in return () }
                        .bind(to: recordVM.deletionSubject)
                        .disposed(by: cell.disposeBag)
                    recordVM.deletionDrv
                        .flatMap({ (error) -> Driver<Int> in
                            guard let err = error else { return Driver.empty() }
                            return self.showAlert(message: err).asDriver(onErrorDriveWith: Driver.never())
                        })
                        .drive()
                        .disposed(by: cell.disposeBag)
                    recordVM.deletionProgressDrv
                        .drive(cell.loadingSpinner.rx.isAnimating)
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
            .flatMap({ (msg) in
                self.showAlert(message: msg).asDriver(onErrorDriveWith: Driver.never())
            })
            .drive()
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
