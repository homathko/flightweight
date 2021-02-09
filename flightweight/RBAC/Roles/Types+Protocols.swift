//
// Created by Eric Lightfoot on 2021-02-08.
//

import Foundation

enum RoleType: String {
    case NEW_USER
    case REGISTERED_USER
    case FOLLOWER
    case PILOT
    case ASSET_OWNER

    func actionDefinitions () -> [Action] {
        switch self {
            case .NEW_USER: return
                    [
                        .SIGN_UP,
                        .LOG_IN,
                        .VIEW_ASSET_TELEMETRY,
                        .VIEW_FEED,
                        .VIEW_LIMITED_PROFILE
                    ]

            case .REGISTERED_USER: return
                    [
                        .LOG_OUT,
                        .UPDATE_PROFILE,
                        .REQUEST_TO_FOLLOW,
                        .DESTROY_ACCOUNT
                    ]

            default: return []
        }
    }

    func actionDefinitions () -> [String] {
        self.actionDefinitions().map { $0.rawValue }
    }
}

protocol UnderscoreIdentifiable {
    associatedtype ID: Hashable
    var _id: ID { get }
}

extension Identifiable where Self : UnderscoreIdentifiable {
    var id: ID {
        _id
    }
}
