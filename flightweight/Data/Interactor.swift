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
    var target: DataTarget<T>
    var cancellable: AnyCancellable?

    init(_ target: DataTarget<T>) {
        self.target = target
    }

    func collection (query: NSPredicate?) -> AnyPublisher<[T], DataError> {
        print("Partition: \(target.path.partitionValue)")
        return Realm.asyncOpen(configuration: target.currentUser.configuration(partitionValue: target.path.partitionValue))
                .flatMap { (realm: Realm) -> RealmPublishers.Value<Results<T>> in
                    realm.objects(T.self)
                        .filter(target.path.query ?? query ?? NSPredicate(value: true))
                        .collectionPublisher
                }
                .mapError { err -> DataError in
                    .realmError(err)
                }
                .map { results -> [T] in
                    Array(results)
                } .eraseToAnyPublisher()

    }

    func update (withFrozenObject frozen: T) where T: Identifiable {
        if frozen.isFrozen {
            let realm = try! Realm(configuration: target.currentUser.configuration(partitionValue: target.path.partitionValue))
            if let object = realm.object(ofType: Role.self, forPrimaryKey: frozen.id) {
                try! realm.write {
                    realm.add(object, update: .modified)
                }
            }
        } else {
            fatalError("Provided non-frozen object to update(withFrozenObject:)")
        }
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