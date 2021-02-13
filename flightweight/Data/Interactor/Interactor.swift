//
// Created by Eric Lightfoot on 2021-02-05.
//

import Foundation
import Combine
import RealmSwift

protocol UserExecutable {

}

enum DataError: Error {
    case realmError(Error)
}

struct Interactor<T: Object> {
    private var target: DataTarget<T>
    var resultPublisher = CurrentValueSubject<T?, Never>(nil)
    var resultsPublisher = CurrentValueSubject<[T], Never>([])

    init (_ target: DataTarget<T>) {
        self.target = target
    }

    private func results (_ query: NSPredicate? = nil) ->
            Publishers.MapError<
                Publishers.FlatMap<
                    RealmPublishers.Value<Results<T>>,
                    RealmPublishers.AsyncOpenPublisher
                >,
                DataError
            >
    {
        Realm.asyncOpen(configuration: target.configuration())
                .flatMap { (realm: Realm) -> RealmPublishers.Value<Results<T>> in
                    realm.objects(T.self)
                            .filter(target.path.query ?? query ?? NSPredicate(value: true))
                            .collectionPublisher
                }
                .mapError { err -> DataError in
                    .realmError(err)
                }
    }

    func collection (query: NSPredicate?) -> AnyPublisher<[T], DataError> {
        results(query)
            .map { results -> CurrentValueSubject<[T], DataError> in
                CurrentValueSubject<[T], DataError>(Array(results))
            }.eraseToAnyPublisher()
    }

    func getFirst (query: NSPredicate?) -> AnyPublisher<T?, DataError> {
//        let p: PassthroughSubject<T?, DataError>

        results(query)
            .map { results -> T? in
                results.first
            }.eraseToAnyPublisher()
    }

    func replaceList<V> (values: [V], keyPath: KeyPath<T, List<V>>, _ object: T)  {
        let realm = object.realm!

        let diff = values.difference(from: object[keyPath: keyPath])

        try! realm.write {
            for change in diff.insertions {
                if case .insert(let index, let value, _) = change {
                    object[keyPath: keyPath].insert(
                            value,
                            at: index
                    )
                }
            }

            for change in diff.removals {
                if case .remove(let index, _, _) = change {
                    object[keyPath: keyPath].remove(at: index)
                }
            }
        }
    }
}

extension Interactor where T: Identifiable {
    func update (withFrozenObject frozen: T) {
        if frozen.isFrozen {
            let realm = try! Realm(configuration: target.configuration())
            if let object = realm.object(ofType: Role.self, forPrimaryKey: frozen.id) {
                try! realm.write {
                    realm.add(object, update: .modified)
                }
            }
        } else {
            fatalError("Provided non-frozen object to update(withFrozenObject:)")
        }
    }
}

extension AnyPublisher where Output == Object?, Failure == DataError {
    func destroy() -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: { (object: Output?) -> () in
            if let object = object {
                if let realm = object?.realm {
                    try! realm.write {
                        realm.delete(object!)
                    }
                }
            }
        })
    }
}