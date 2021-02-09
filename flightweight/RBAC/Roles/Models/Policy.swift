//
// Created by Eric Lightfoot on 2021-02-08.
//

import Foundation.NSObjCRuntime
import RealmSwift

class Policy: EmbeddedObject {
    @objc dynamic var access: Int = 0
    @objc dynamic var target_ref: String = ""

    var accessLevel: SyncPermissionAccessLevel {
        SyncPermissionAccessLevel(rawValue: access)!
    }
    convenience init (targetRef: String, accessLevel: SyncPermissionAccessLevel) {
        self.init()
        access = accessLevel.rawValue
        target_ref = targetRef
    }
}
