//
// Created by Eric Lightfoot on 2020-12-07.
// Copyright (c) 2020 HomathkoTech. All rights reserved.
//

import Foundation.NSObjCRuntime
import RealmSwift

class Role: Object, Identifiable {
    @objc dynamic var _id = ObjectId.generate()
    @objc dynamic var user_id: String = ""
    @objc dynamic var name: String = "" /// i.e. NEW_USER, REGISTERED_USER, FOLLOWER, PILOT, ASSET_OWNER
    let actions = List<String>()
    let policies = List<Policy>()

    var type: RoleType {
        get {
            RoleType(rawValue: name)!
        }
        set {
            name = newValue.rawValue
        }
    }

    convenience init (type: RoleType, user: User, actions: [Action], policies: [Policy]) {
        self.init()
        self.type = type
        user_id = user.id
        for action in actions {
            self.actions.append(action.rawValue)
        }
        for policy in policies {
            self.policies.append(policy)
        }
    }

    override class func primaryKey () -> String? {
        "_id"
    }
}