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
import FirebaseAuth

class BMIController: UIViewController {

    @IBOutlet weak var signOutBarBtn: UIBarButtonItem!
    @IBOutlet weak var bmiCollections: UICollectionView!

    var welcomeController: WelcomeController?
    let gidAuthService = GIDAuthService.instance
    let disposeBag = DisposeBag()

    fileprivate var items: [String] {
        var collection: [String] = .init()
        for i in 1...80 {
            collection.append("BMI-\(i)")
        }
        return collection
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        signOutBarBtn.rx.tap.asObservable()
            .subscribe(onNext: { _ in
                do {
                    try Auth.auth().signOut()
                }catch {
                    print(error)
                }
            }).disposed(by: disposeBag)

        Auth.auth().rx
            .authStateChangeDidChange()
            .subscribe(onNext: { (result) in
                guard result.1 != nil else {
                    self.performSegue(withIdentifier: "segue_BMI_requestAuth", sender: nil)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "segue_BMI_requestAuth":
            welcomeController = segue.destination as? WelcomeController
            welcomeController?.viewModel = WelcomeViewModel(gidAuth: gidAuthService)

        default:
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BMIController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "BMICell"

        let cell: BMICell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BMICell
        cell.backgroundColor = UIColor.gray
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
