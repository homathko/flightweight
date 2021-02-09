//
// Created by Eric Lightfoot on 2021-02-08.
//

import Foundation
import RealmSwift

extension RoleController {
    func addAnonymousRole (user: User) {
        let configuration = user.configuration(partitionValue: "/\(user.id)/user")
        let realm = try! Realm(configuration: configuration)

        let anonRole = Role(
                type: .NEW_USER,
                user: user,
                actions: RoleType.NEW_USER.actionDefinitions(),
                policies: [
                    Policy(
                            targetRef: "/",
                            accessLevel: .write
                    ),
                    Policy(
                            targetRef: "/directory",
                            accessLevel: .read
                    ),
                    Policy(
                            targetRef: "/feed",
                            accessLevel: .read
                    )
                ])

        try! realm.write {
            realm.add(anonRole, update: .modified)
        }
    }

    func upgradeToRegisteredUserRole (user: User) {
        let configuration = user.configuration(partitionValue: "/\(user.id)/user")
        let realm = try! Realm(configuration: configuration)

        let regRole = Role(
                type: .REGISTERED_USER,
                user: user,
                actions: RoleType.REGISTERED_USER.actionDefinitions(),
                policies: [
                    Policy(
                            targetRef: "/",
                            accessLevel: .write
                    ),
                    Policy(
                            targetRef: "/\(user.id)/user",
                            accessLevel: .write
                    )
                ])

        try! realm.write {
            let destroyed = realm.objects(Role.self).filter {
                $0.name == "NEW_USER"
            }
            realm.delete(destroyed)
            realm.add(regRole, update: .modified)
        }
    }
}
