//
// Created by Eric Lightfoot on 2021-02-05.
//

import Foundation
import RealmSwift

extension Object {
    var typeString: String {
        String(format: "%@", "\(type(of: self))")
    }
}

struct DataTarget<T: Object> {
    var currentUser: User
    var path: DataTargetPath

    init (path: DataTargetPath, _ currentUser: User) {
        self.path = path
        self.currentUser = currentUser
    }

    func configuration () -> Realm.Configuration {
        currentUser.configuration(partitionValue: path.partitionValue)
    }
}

extension DataTarget {

    /// Targets a collection of entities of the same type at the location
    init (
            domain: Constants.Paths.DomainPathComponent.Realm,
            location: Constants.Paths.LocationPathComponent.RealmDatabase,
            _ currentUser: User
    ) {
        self.init(path:
        DataTargetPath(
                service: .Sync,
                domain: domain.refKey(),
                location: location.refKey(),
                objectType: T().typeString,
                query: nil,
                id: nil
        ), currentUser
        )
    }

    /// Targets a collection of entities of the same type with a built in query
    init (
            domain: Constants.Paths.DomainPathComponent.Realm,
            location: Constants.Paths.LocationPathComponent.RealmDatabase,
            query: NSPredicate,
            _ currentUser: User
    ) {
        self.init(path:
        DataTargetPath(
                service: .Sync,
                domain: domain.refKey(),
                location: location.refKey(),
                objectType: T().typeString,
                query: query,
                id: nil
        ), currentUser
        )
    }
}

extension DataTarget where T : UnderscoreIdentifiable {

    /// Targets one known entity at the location
    init (
            domain: Constants.Paths.DomainPathComponent.Realm,
            location: Constants.Paths.LocationPathComponent.RealmDatabase,
            id: T.ID,
            _ currentUser: User
    ) {
        self.init(path:
            DataTargetPath(
                    service: .Sync,
                    domain: domain.refKey(),
                    location: location.refKey(),
                    objectType: T().typeString,
                    query: nil,
                    id: id!
            ), currentUser
        )
    }
}

protocol StaticData { }

extension DataTarget where T: StaticData {
    init (
            domain: Constants.Paths.DomainPathComponent.Mongo,
            location: Constants.Paths.LocationPathComponent.MongoDatabase,
            _ currentUser: User
    ) {
        self.init(path:
            DataTargetPath(
                    service: .Static,
                    domain: domain.refKey(),
                    location: location.refKey(),
                    objectType: T().typeString,
                    query: nil,
                    id: nil
            ), currentUser
        )
    }
}