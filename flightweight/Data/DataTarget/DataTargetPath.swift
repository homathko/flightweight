//
// Created by Eric Lightfoot on 2021-02-05.
//

import Foundation

internal struct DataTargetPath {
    let service: Constants.Paths.ServicePathComponent
    let domain: Constants.Paths.DomainPathComponent
    let location: Constants.Paths.LocationPathComponent
    let objectType: String
    let query: NSPredicate?
    let id: String?

    var partitionValue: String {
        String(format: "/%@/%@", domain.component(), location.component())
    }

    var encoded: String {
        String(
                format: "/%@/%@/%@.%@/%@",
                service.component(),
                domain.component(),
                location.component(),
                objectType,
                id != nil ? "\(id!)" : ""
        )
    }


}

extension DataTargetPath: Encodable {
    func encode (to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(service.component(), forKey: .service)
        try container.encode(domain.component(), forKey: .domain)
        try container.encode(location.component(), forKey: .location)
        try container.encode(objectType, forKey: .type)
        if let id = id {
            try container.encode(id, forKey: .id)
        }
    }

    enum CodingKeys: CodingKey {
        case service, domain, location, type, id
    }
}