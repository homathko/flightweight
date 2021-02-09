//
// Created by Eric Lightfoot on 2021-02-05.
//

import Foundation
import RealmSwift

protocol DatabasePathComponentAvailable {
    func component() -> String
}

protocol RealmDatabaseObjectMapAvailable {
    func objectTypes () -> [Object.Type]
}

struct Constants {

    ///
    /// Service: MongoDB Realm Sync
    ///
    static let RealmAppId = "login-flow-jjfpx"
    ///
    ///
    static var MongoDBRealmSyncClusterServiceName: String { "sync" }
    static var MongoDBStaticClusterServiceName: String { "static" }

    enum Paths {

        enum ServicePathComponent {
            case Sync
            case Static
            func component() -> String {
                switch self {
                    case .Sync: return Constants.MongoDBRealmSyncClusterServiceName
                    case .Static: return Constants.MongoDBStaticClusterServiceName
                }
            }
        }

        enum DomainPathComponent {

            case sync(Realm)
            case `static`(Mongo)

            enum Realm {
                case global
                case user(String)

                func component() -> String {
                    switch self {
                        case .global:
                            return ""
                        case .user(let id):
                            return "\(id)"
                    }
                }

                func refKey () -> DomainPathComponent {
                    .sync(self)
                }
            }

            enum Mongo {
                case all
                func component () -> String { "" }
                func refKey () -> DomainPathComponent {
                    .static(self)
                }
            }

            func component () -> String {
                switch self {
                    case .sync(let subValue):
                        return subValue.component()
                    case .static(let subValue):
                        return subValue.component()
                }
            }
        }

        enum LocationPathComponent {
            case realm(RealmDatabase)
            case staticData(MongoDatabase)

            enum RealmDatabase: DatabasePathComponentAvailable, RealmDatabaseObjectMapAvailable {

                case user
                case feed
                case cycles
                case assets
                case directory

                func component() -> String {
                    switch self {
                        case .user:
                            return "user"
                        case .feed:
                            return "feed"
                        case .cycles:
                            return "cycles"
                        case .assets:
                            return "assets"
                        case .directory:
                            return "directory"
                    }
                }

                func objectTypes () -> [Object.Type] {
                    switch self {
                        case .user:
                            return [Role.self]
                        case .feed:
                            return [/*_SharedAsset.self, _Notification.self, _Request.self, _Following.self, _Follower.self, _Event.self*/]
                        case .directory:
                            return [/*_PilotListing.self, _AssetListing.self, _DeviceListing.self, _DeviceAircraftProfile.self*/]
                        case .cycles:
                            return [/*_Cycle.self, _FlightEvent.self*/]
                        case .assets:
                            return [/*_AssetIdentity.self*/]
                    }
                }

                func refKey () -> LocationPathComponent {
                    realm(self)
                }
            }

            enum MongoDatabase {
                case places
                case aircraft
                func component () -> String {
                    switch self {
                        case .places: return "places"
                        case .aircraft: return "aircraft"
                    }
                }
                func refKey () -> LocationPathComponent {
                    .staticData(self)
                }
            }

            func component () -> String {
                switch self {
                    case .realm(let subValue):
                        return subValue.component()
                    case .staticData(let subValue):
                        return subValue.component()
                }
            }
        }
    }
}