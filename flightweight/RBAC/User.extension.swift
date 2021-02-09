//
// Created by Eric Lightfoot on 2021-02-04.
//

import Foundation
import RealmSwift

extension AppState {
    func can <T>(_ action: Action, target: DataTarget<T>?) -> Bool {
        if let user = app.currentUser {
            return user.can(action, target: target, self)
        } else {
            return false
        }
    }

    func has (role: Role) -> Bool {
        if let user = app.currentUser {
            return user.has(role: role, self)
        } else {
            return false
        }
    }
}

extension User {
    func can <T> (_ action: Action, target: DataTarget<T>?, _ appState: AppState) -> Bool {
        /// In any role belonging to this user that contains the action,
        /// find a policy fpr the targetId (resource) and
        /// the requisite effect of 'allow'
        let policies = appState.roleController.roles.first { role in
            /// Actions are unique and distinct between roles, so
            /// the first role containing this action is the one we want
            role.actions.contains(action.rawValue)
        }.flatMap {
            /// Assemble array of policies
            $0.policies
        }?.filter {
            $0.target_ref == target?.path.partitionValue ?? "/" &&
            $0.accessLevel == action.requiredAccessLevel
        }

        return policies?.count ?? 0 > 0
    }

    func has (role: Role, _ appState: AppState) -> Bool {
        appState.roleController.roles.contains { $0.type == role.type }
    }
}