//
// Created by Eric Lightfoot on 2021-02-08.
//

import Foundation
import Combine

/**
 RoleController.swift

 Responsible for maintaining constant access to current (synced) data.
 Also responsible for updating synced Role objects with new actions

 */
class RoleController: ObservableObject {
    @Published var roles: [Role] = []

    private var coordinator: RoleCoordinator
    var cancellables = Set<AnyCancellable>()

    init (appState: AppState) {
        coordinator = RoleCoordinator(appState: appState)

        coordinator.$roles.receive(on: DispatchQueue.main).sink { roles in
                    for role in roles {
                        if self.shouldUpdate(actionDefinitionForRole: role) {
                            self.coordinator.update(actionDefinitionForRole: role)
                        }
                    }

                    self.roles = roles
                } .store(in: &cancellables)
    }

    private func shouldUpdate (actionDefinitionForRole role: Role) -> Bool {
        !Array(role.actions).containsSameElements(as: role.type.actionDefinitions().map {
            $0.rawValue
        })
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        count == other.count && self.sorted() == other.sorted()
    }
}