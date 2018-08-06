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
            //setupCreateBMIViewModel(vc?.generateViewModel())

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
                    cell.heightLbl.text = String(format: "%.2f m", height / 100)
                    cell.weightLbl.text = String(format: "%.0f kg", weight)
                    cell.dateLbl.text = timestamp
                    return cell

                case let .error(err):
                    let cell = cv.dequeueReusableCell(withReuseIdentifier: "BMIErrorCell", for: indexPath) as! BMIErrorCell
                    cell.errorLbl.text = err
                    cell.reloadBtn.rx.tap
                        .asDriver().drive(vm.reloadSubject)
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
                let collectionViewLayout = cv.collectionViewLayout as? UICollectionViewFlowLayout
                collectionViewLayout?.sectionHeadersPinToVisibleBounds = true

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

    /*
    fileprivate func setupCreateBMIViewModel(_ creationVM: CreateBMIViewModel?) {

        guard let vm = bmiViewModel, let cvm = creationVM else { return }
        vm.submitRecordOnTap(
            cvm.submittedDrv.asObservable()
                .skipWhile({ (data) -> Bool in
                    if data != nil {
                        self.dismiss(animated: true, completion: nil)
                    }
                    return data == nil
                })
            ).disposed(by: disposeBag)
    }
    */
}

extension BMIController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let dataSrc = bmiCollectionDataSrc else { return CGSize.zero }

        switch dataSrc[indexPath] {
        case .record:
            return CGSize(width: collectionView.frame.size.width - 24.0, height: 88.0)
        default:
            return CGSize(width: collectionView.frame.size.width, height: 400.0)
        }
    }
}
