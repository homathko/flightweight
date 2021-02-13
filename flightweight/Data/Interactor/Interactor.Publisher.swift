//
// Created by Eric Lightfoot on 2021-02-09.
//

import Foundation.NSObjCRuntime
import Combine

/// For Combine to wrap CRUD operations, we specify whether the read is "one-shot" or
/// "continuous". Certain write operations (except Creat) can only be associated with
/// one of those two categories.
///
/// For instance deleting the output of a one-shot operation makes sense. Use Future.
/// Updating elements from a stream could find a use case. But mostly, CRUD operations
/// should all be applicable to one-shot Future ops except for read.
///
/// Two read stream categories: Results (ref), and Changesets (which also contain Results ref)
/// Other CRUD op results are C_UD Future<Void, InteractorError>, and _R__ Future<T?, InteractorError>
///

extension Interactor {
//    func resultPublisher () -> CurrentValueSubject<T?, Never> {
//        CurrentValueSubject<T?, Never>(nil)
//    }
//
//    func resultsPublisher () -> CurrentValueSubject<[T]?, Never> {
//        CurrentValueSubject<[T]?, Never>(nil)
//    }
}