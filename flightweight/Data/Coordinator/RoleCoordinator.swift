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
                            self.roles = roles
                        }) .store(in: &cancellables)
    }

    func update (actionDefinitionForRole role: Role) {
        roleInteractor?.replaceList(values: role.type.actionDefinitions(), keyPath: \.actions, role)
    }

    deinit {
        print("Coordinator deinit")
    }
}