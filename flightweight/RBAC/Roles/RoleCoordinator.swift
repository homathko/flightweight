//
// Created by Eric Lightfoot on 2021-02-04.
//

import Foundation
import RealmSwift
import Combine

protocol AuthenticationRequired { }

class RoleCoordinator: Coordinator {
    @Published var roles = [Role]()
    private var numberOfRuns = 0
    var token: NotificationToken?
    private var roleInteractor: Interactor<Role>?

    init (appState: AppState) {
        super.init(app: appState)
    }

    override func run (withEnsuredUser user: User) {
        numberOfRuns += 1
        print("Running interactor: #\(numberOfRuns)")

        let target = DataTarget<Role>(domain: .user(user.id), location: .user, user)

        for cancellable in cancellables { cancellable.cancel() }
        cancellables = Set<AnyCancellable>()

        roleInteractor = Interactor(target)
        roleInteractor!.collection(query: nil).sink(
                        receiveCompletion: { _ in
                            print("Completion received")
                        }, receiveValue: { roles in

                            for role in roles {
                                if self.shouldUpdate(actionDefinitionForRole: role) {
                                    self.update(actionDefinitionForRole: role)
                                }
                            }

                            self.roles = roles
                        }) .store(in: &cancellables)
    }

    private func update (actionDefinitionForRole role: Role) {
        roleInteractor?.replaceList(values: role.type.actionDefinitions(), keyPath: \.actions, role)
    }

    private func shouldUpdate (actionDefinitionForRole role: Role) -> Bool {
        !Array(role.actions).containsSameElements(as: role.type.actionDefinitions().map {
            $0.rawValue
        })
    }

    deinit {
        print("Coordinator deinit")
    }
}

extension RoleCoordinator {
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

        let target = DataTarget<Role>(domain: .user(user.id), location: .user, user)
        Interactor(target)
                .getFirst(query: NSPredicate(format: "name == %@", RoleType.NEW_USER.rawValue))
//                .compactMap { optional -> Role? in
//                    optional
//                }.eraseToAnyPublisher()
                .destroy()

        try! realm.write {
            let destroyed = realm.objects(Role.self).filter {
                $0.name == "NEW_USER"
            }
            realm.delete(destroyed)
            realm.add(regRole, update: .modified)
        }
    }
}

extension Array where Element : Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        count == other.count && self.sorted() == other.sorted()
    }
}