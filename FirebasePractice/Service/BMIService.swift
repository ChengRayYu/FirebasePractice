//
//  BMIService.swift
//  FirebasePractice
//
//  Created by Ray on 2018/7/12.
//  Copyright © 2018 ycray.net. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
import GoogleSignIn
import FirebaseStorage
import FirebaseDatabase

class BMIService { }

// MARK: - Authentication

extension BMIService {

    static func authStateChanged() -> Observable<Response<User?>> {

        return Auth.auth().rx
            .authStateDidChange()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (authResult) -> Response<User?> in
                return .success(resp: authResult.1)
            })
            .catchError({ (error) -> Observable<Response<User?>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }

    static func createUser(withEmail email: String, password: String) -> Observable<Response<User?>> {

        return Auth.auth().rx
            .createUser(email: email, password: password)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (user) -> Response<User?> in
                guard let user = user else { return .fail(err: .unauthenticated) }
                return .success(resp: user)
            })
            .catchError({ (error) -> Observable<Response<User?>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }

    static func signIn(withEmail email: String, password: String) -> Observable<Response<User?>> {

        return Auth.auth().rx
            .signIn(email: email, password: password)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (user) -> Response<User?> in
                guard let user = user else { return .fail(err: .unauthenticated) }
                return .success(resp: user)
            })
            .catchError({ (error) -> Observable<Response<User?>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }

    static func signInViaGoogle() -> Observable<Response<AuthCredential?>> {

        return GIDSignIn.sharedInstance().rx.didSignIn
            .asObservable()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (result) -> Response<AuthCredential?> in
                if let err = result.error {
                    return .fail(err: handleError(err))
                }
                guard let authentication = result.user.authentication,
                    let idToken = authentication.idToken,
                    let accessToken = authentication.accessToken else {
                        return .fail(err: .unauthenticated)
                }
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                return .success(resp: credential)
            })
            .take(1)
    }

    static func signIn(withCredential cred: AuthCredential) -> Observable<Response<User?>> {

        return Auth.auth().rx
            .signIn(credential: cred)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (user) -> Response<User?> in
                guard let user = user else { return .fail(err: .unauthenticated) }
                return .success(resp: user)
            })
            .catchError({ (error) -> Observable<Response<User?>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }

    static func signOut() -> Observable<Response<Void>> {
        return Auth.auth().rx
            .signOut()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ _ -> Response<Void> in
                return .success(resp: ())
            })
            .catchError({ (error) -> Observable<Response<Void>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }
}

// MARK: - UserInfo Operations

extension BMIService {

    static func initializeProfile() -> Observable<Response<Void>> {
        guard let user = Auth.auth().currentUser else {
            return Observable.just(.fail(err: .unauthenticated))
        }
        let usersRef = Database.database().reference().child("users")
        return usersRef
            .rx
            .observeSingleEvent(.value)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (snapshot) -> Bool in
                return snapshot.hasChild(user.uid)
            })
            .skipWhile { $0 }
            .flatMap({ (userInfoResp) -> Observable<Void> in
                guard let photoURL = user.photoURL else {
                    return Observable.empty()
                }
                return updateUserPortrait(fromURL: photoURL)
                    .map { _  in }
            })
            .flatMap({ (url) -> Observable<Response<Void>> in
                return usersRef.child(user.uid).rx
                    .setValue([UserInfoEditType.email.rawValue: user.email ?? "",
                               UserInfoEditType.username.rawValue: user.displayName ?? "",
                               UserInfoEditType.gender.rawValue: -1,
                               UserInfoEditType.age.rawValue: -1])
                               //UserInfoEditType.portrait.rawValue: url?.absoluteString ?? ""])
                    .map({ (ref) -> Response<Void> in
                        return .success(resp: ())
                    })
                    .catchError({ (error) -> Observable<BMIService.Response<Void>> in
                        return Observable.just(.fail(err: handleError(error)))
                    })
            })
    }

    static func fetchUserInfo() -> Observable<Response<UserInfo>> {
        guard let user = Auth.auth().currentUser else {
            return Observable.just(.fail(err: .unauthenticated))
        }
        let userRef = Database.database().reference().child("users/\(user.uid)")
        return userRef.rx
            .observeEvent(.value)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (snapshot) -> Response<UserInfo> in
                guard let entries = snapshot.value as? [String: AnyObject],
                    let email = entries[UserInfoEditType.email.rawValue] as? String,
                    let username = entries[UserInfoEditType.username.rawValue] as? String,
                    let gender = Gender(rawValue: ((entries[UserInfoEditType.gender.rawValue] as? NSNumber))?.intValue ?? Int.min),
                    let ageRange = AgeRange(rawValue: ((entries[UserInfoEditType.age.rawValue] as? NSNumber))?.intValue ?? Int.min) else {
                    //let portrait = entries[UserInfoEditType.portrait.rawValue] as? String else {
                        return .fail(err: .service(msg: "Fetch user info failed"))
                }
                let userInfo = (email, username, gender, ageRange)//, portrait)
                return .success(resp: userInfo)
            })
            .catchError({ (error) -> Observable<Response<UserInfo>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }

    static func fetchUserInfo(ofType type: UserInfoEditType) -> Observable<Response<Any>> {
        guard let user = Auth.auth().currentUser else {
            return Observable.just(.fail(err: .unauthenticated))
        }
        let userInfoRef = Database.database().reference().child("users/\(user.uid)/\(type.rawValue)")
        return userInfoRef.rx
            .observeSingleEvent(.value)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map { (snapshot) -> Response<Any> in
                return .success(resp: snapshot.value!)
            }
            .catchError({ (error) -> Observable<Response<Any>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }

    static func saveUserInfo(_ content: Any, ofType type: UserInfoEditType) -> Observable<Response<Void>> {
        guard let user = Auth.auth().currentUser else {
            return Observable.just(.fail(err: .unauthenticated))
        }
        let contentRef = Database.database().reference().child("users/\(user.uid)/\(type.rawValue)")
        return contentRef
            .rx
            .setValue(content)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (ref) -> Response<Void> in
                return .success(resp: ())
            })
            .catchError({ (error) -> Observable<Response<Void>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }

    static func updateUserPortrait(fromURL url: URL) -> Observable<Response<Void>> {
        guard let user = Auth.auth().currentUser else {
            return Observable.just(.fail(err: .unauthenticated))
        }
        return URLSession.shared.rx.response(request: URLRequest(url: url))
            .map({ (response, data) -> Data? in
                if 200 ..< 300 ~= response.statusCode {
                    return data
                }
                return nil
            })
            .catchError({ (error) -> Observable<Data?> in
                return Observable.just(nil)
            })
            .observeOn(MainScheduler.instance)
            .flatMap({ (portraitData) -> Observable<Response<Void>> in
                guard let portrait = portraitData else {
                    return Observable.just(.fail(err: .service(msg: "Invalid image source")))
                }
                let storageRef = Storage.storage().reference().child("/portraits/\(user.uid).jpg")
                return storageRef
                    .rx
                    .putData(portrait)
                    .map({ (metadata) -> Response<Void> in
                        return .success(resp: ())
                    })
                    .catchError({ (error) -> Observable<BMIService.Response<Void>> in
                        return Observable.just(.fail(err: handleError(error)))
                    })
            })
    }

    static func updateUserPortrait(fromImage image: UIImage) -> Observable<Response<Void>> {
        guard let data = UIImageJPEGRepresentation(image, 0.8) else {
            return Observable.just(.fail(err: .service(msg: "Invalid image content")))
        }
        guard let user = Auth.auth().currentUser else {
            return Observable.just(.fail(err: .unauthenticated))
        }
        let storageRef = Storage.storage().reference().child("/portraits/\(user.uid).jpg")
        return storageRef
            .rx
            .putData(data)
            .observeOn(MainScheduler.instance)
            .map({ (metadata) -> Response<Void> in
                return .success(resp: ())
            })
            .catchError({ (error) -> Observable<Response<Void>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }

    static func fetchUserPortraitURL() -> Observable<Response<URL>> {
        guard let user = Auth.auth().currentUser else {
            return Observable.just(.fail(err: .unauthenticated))
        }
        let storageRef = Storage.storage().reference().child("/portraits/\(user.uid).jpg")
        return storageRef
            .rx
            .downloadURL()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (url) -> Response<URL> in
                return .success(resp: url)
            })
            .catchError({ (error) -> Observable<Response<URL>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }
}

// MARK: - BMI Record Operations

extension BMIService {

    static func fetchRecords() -> Observable<Response<[Record]>> {
        guard let user = Auth.auth().currentUser else {
            return Observable.just(.fail(err: .unauthenticated))
        }
        return Database.database().reference().child("records/\(user.uid)")
            .queryOrderedByKey()
            .rx
            .observeEvent(.value)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (snapshot) -> Response<[Record]> in
                let records =  snapshot.children
                    .reversed()
                    .map({ (child) -> Record in
                        let childSnapshot = child as! DataSnapshot
                        let entries = childSnapshot.value as! [String: AnyObject]
                        return (childSnapshot.key,
                                entries["h"]?.doubleValue ?? 0,
                                entries["w"]?.doubleValue ?? 0)
                    })
                return .success(resp: records)
            })
            .catchError({ (error) -> Observable<Response<[Record]>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }

    static func createRecord(height: Double, weight: Double) -> Observable<Response<Void>> {
        guard let user = Auth.auth().currentUser else {
            return Observable.just(.fail(err: .unauthenticated))
        }
        let userRecordRef = Database.database().reference().child("records/\(user.uid)")
        let timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        return userRecordRef
            .child(timestamp)
            .rx
            .setValue(["h": NSNumber(value: height), "w": NSNumber(value: weight)])
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (ref) -> Response<Void> in
                return .success(resp: ())
            })
            .catchError({ (error) -> Observable<BMIService.Response<Void>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }

    static func deleteRecord(_ timestamp: String) -> Observable<Response<Void>> {

        guard let user = Auth.auth().currentUser else {
            return Observable.just(.fail(err: .unauthenticated))
        }
        let userRecordRef = Database.database().reference().child("records/\(user.uid)")
        return userRecordRef
            .child(timestamp)
            .rx
            .removeValue()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map({ (ref) -> Response<Void> in
                return .success(resp: ())
            })
            .catchError({ (error) -> Observable<BMIService.Response<Void>> in
                return Observable.just(.fail(err: handleError(error)))
            })
    }
}

// MARK: - Private Method

fileprivate extension BMIService {

    fileprivate static func handleError(_ error: Error) -> Err {

        if error._domain == "FIRAuthErrorDomain", let code = AuthErrorCode(rawValue: error._code) {
            return .auth(code: code, msg: error.localizedDescription)
        }
        if error._domain == "com.google.GIDSignIn", let code = GIDSignInErrorCode(rawValue: error._code) {
            return .gAuth(code: code, msg: error.localizedDescription)
        }
        if error._domain == "FIRStorageErrorDomain", let code = StorageErrorCode(rawValue: error._code) {
            return .storage(code: code, msg: error.localizedDescription)
        }
        return .service(msg: error.localizedDescription)
    }
}

