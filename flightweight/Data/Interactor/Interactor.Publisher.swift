//
// Created by Eric Lightfoot on 2021-02-09.
//

import Foundation
import Combine
import RealmSwift

/// For Combine to wrap CRUD operations, we specify whether the read is "one-shot" or
/// "continuous". Certain write operations (except Creat) can only be associated with
/// one of those two categories.
///
/// For instance deleting the output of a one-shot operation makes sense. Use Future.
/// Updating elements from a stream could find a use case. But mostly, CRUD operations
/// should all be applicable to one-shot Future ops except for read.
///
/// Two read stream categories: Results (ref), and Changesets (which also contain Results ref)
/// Other CRUD op results are C_UD Future<Void, InteractorError>, and _R__ Future<T?, InteractorError>
///
extension Interactor {
    
    func create (_ object: T) -> Future<T, Never> {
        Future { promise in
            self.connect()
                .sink { realm in
                    
                    try! realm.write {
                        realm.add(object)
                    }
                    
                    promise(.success(object))
                }
        }
    }
    
    func getOnce (query: NSPredicate? = nil) -> Future<[T], Never> {
        Future { promise in
            self.connect()
                .flatMap { (realm: Realm) -> RealmPublishers.Value<Results<T>> in
                    realm
                        .objects(T.self)
                        .filter(query ?? target.path.query ?? NSPredicate(value: true))
                        .collectionPublisher
                }
                .assertNoFailure()
                .sink { results in
                    promise(.success(Array(results.freeze())))
                }
//                .store(in: &self.cancellables)
            /// Perhaps the subscriber who connects here will store the cancellable
        }
    }
    
}

extension Interactor where T : Identifiable {
    func getOnce (id: T.ID) -> Future<T, Never> {
        Future { promise in
            self.connect()
                .flatMap { (realm: Realm) -> Optional<T>.Publisher in
                    realm
                        .object(ofType: T.self, forPrimaryKey: id)
                        .publisher
                }
                .assertNoFailure()
                .sink { result in
                    promise(.success(result.freeze()))
                }
//                .store(in: &self.cancellables)
        }
    }
}

class Delete<T: Object>: Subscriber {
    typealias Input = T
    typealias Failure = Never
    
    func receive (subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    func receive(_ input: T) -> Subscribers.Demand {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(input)
        }
        return .none
    }
        
    func receive(completion: Subscribers.Completion<Never>) {
        print("Completion event:", completion)
    }
}

extension Future where Output == Object, Failure == Never {
    func delete () {
        receive(subscriber: Delete())
    }
}
