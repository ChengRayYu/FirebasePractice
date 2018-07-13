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

class BMIController: UIViewController {

    @IBOutlet weak var bmiCollections: UICollectionView!

    fileprivate var welcomeController: WelcomeController?
    fileprivate let disposeBag = DisposeBag()

    fileprivate var items: [String] {
        var collection: [String] = .init()
        for i in 1...20 {
            collection.append("BMI-\(i)")
        }
        return collection
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup(withModel: BMIViewModel())
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "segue_BMI_requestAuth":
            welcomeController = segue.destination as? WelcomeController
        default:
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BMIController {

    fileprivate func setup(withModel viewModel: BMIViewModel) {

        bmiCollections.rx.setDelegate(self).disposed(by: disposeBag)
        bmiCollections.rx.setDataSource(self).disposed(by: disposeBag)

        viewModel.loggedInDrv
            .asObservable()
            .subscribe(onNext: { (flag) in
                self.dismiss(animated: true, completion: nil)
                if flag != true {
                    self.performSegue(withIdentifier: "segue_BMI_requestAuth", sender: nil)
                }
            })
            .disposed(by: disposeBag)


        viewModel.recordsDrv
            .asObservable()
            .subscribe(onNext: { (records) in
                print("RELOAD DATA - VIA BINDING TO COLLECTIONVIEW")
                print(records)
            })
            .disposed(by: disposeBag)
    }
}

extension BMIController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BMICell = collectionView.dequeueReusableCell(withReuseIdentifier: "BMICell", for: indexPath) as! BMICell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionHeadersPinToVisibleBounds = true

        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BMIHeader", for: indexPath) as! BMIHeader
            return headerView

        default:
            assert(false, "Unexpected element kind")
        }
    }
}

extension BMIController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 24.0, height: 88.0)
    }
}
