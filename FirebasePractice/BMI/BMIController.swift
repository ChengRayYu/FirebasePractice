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
import FirebaseDatabase

class BMIController: UIViewController {

    @IBOutlet weak var bmiCollections: UICollectionView!

    fileprivate var bmiViewModel: BMIViewModel?
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBMIViewModel(BMIViewModel())
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "segue_BMI_CreateRecord":
            let vc = segue.destination as? CreateBMIController
            vc?.loadView()
            setupCreateBMIViewModel(vc?.generateViewModel())

        default:
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BMIController {

    fileprivate func setupBMIViewModel(_ viewModel: BMIViewModel) {
        bmiCollections.rx.setDelegate(self).disposed(by: disposeBag)
        bmiViewModel = viewModel

        viewModel.loggedInDrv
            .asObservable()
            .subscribe(onNext: { (flag) in
                self.dismiss(animated: true, completion: nil)
                if flag != true {
                    self.performSegue(withIdentifier: "segue_BMI_requestAuth", sender: nil)
                }
            })
            .disposed(by: disposeBag)

        let bmiCollectionDataSrc = RxCollectionViewSectionedReloadDataSource<SectionModel<String, BMIRecordService.Record>>(
            configureCell: { (data, cv, indexPath, item) -> UICollectionViewCell in
                let cell = cv.dequeueReusableCell(withReuseIdentifier: "BMICell", for: indexPath) as! BMICell
                cell.resultLbl.text = String(format: "%2.2f", item.weight / pow(item.height / 100, 2.0))
                cell.heightLbl.text = String(format: "%.2f m", item.height / 100)
                cell.weightLbl.text = String(format: "%.0f kg", item.weight)
                cell.dateLbl.text = item.timestamp
                return cell
            },
            configureSupplementaryView: { (dataSrc, cv, kind, indexPath) -> UICollectionReusableView in
                let collectionViewLayout = cv.collectionViewLayout as? UICollectionViewFlowLayout
                collectionViewLayout?.sectionHeadersPinToVisibleBounds = true

                switch kind {
                case UICollectionElementKindSectionHeader:
                    return cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BMIHeader", for: indexPath) as! BMIHeader
                default:
                    assert(false, "Unexpected element kind")
                }
            })

        viewModel.recordsDrv
            .asObservable()
            .map({ (records) -> [SectionModel<String, BMIRecordService.Record>] in
                return [SectionModel(model: "", items: records)]
            })
            .bind(to: bmiCollections.rx.items(dataSource: bmiCollectionDataSrc))
            .disposed(by: disposeBag)
    }

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
}

extension BMIController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 24.0, height: 88.0)
    }
}
