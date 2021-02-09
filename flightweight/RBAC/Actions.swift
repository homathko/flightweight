//
// Created by Eric Lightfoot on 2021-02-04.
//

import Foundation

enum SyncPermissionAccessLevel: Int {
    case none = 0
    case read
    case write
}

enum Action: String {
    /// Anonymous Actions Group
    case SIGN_UP
    case LOG_IN
    case VIEW_ASSET_TELEMETRY
    case VIEW_FEED
    case VIEW_LIMITED_PROFILE

    /// Registered User Actions Group
    case LOG_OUT
    case UPDATE_PROFILE
    case REQUEST_TO_FOLLOW
    case DESTROY_ACCOUNT

    /// Follower Actions Group
    case VIEW_FULL_PROFILE
    case VIEW_DETAILS_IN_FEED
    case VIEW_ACTIVITY
    case WAVE

    /// Pilot Actions Group
    case ACTIVATE_BEACON
    case DEACTIVATE_BEACON
    case REQUEST_TO_JOIN_ASSET
    case LEAVE_ASSET

    case CREATE_ASSET

    /// Asset Owner Actions Group
    case UPDATE_ASSET
    case APPROVE_JOIN_ASSET_REQUEST
    case REMOVE_FROM_ASSET
    case DESTROY_ASSET

    var requiredAccessLevel: SyncPermissionAccessLevel {
        switch self {
            case .LOG_IN,
                 .VIEW_FEED,
                 .VIEW_ASSET_TELEMETRY,
                 .VIEW_LIMITED_PROFILE,
                 .VIEW_FULL_PROFILE,
                 .VIEW_DETAILS_IN_FEED,
                 .VIEW_ACTIVITY:
                    return .read

            case .SIGN_UP,
                 .LOG_OUT,
                 .UPDATE_PROFILE,
                 .REQUEST_TO_FOLLOW,
                 .DESTROY_ACCOUNT,
                 .WAVE,
                 .REQUEST_TO_JOIN_ASSET,
                 .LEAVE_ASSET,
                 .CREATE_ASSET,
                 .UPDATE_ASSET,
                 .APPROVE_JOIN_ASSET_REQUEST,
                 .REMOVE_FROM_ASSET,
                 .ACTIVATE_BEACON,
                 .DESTROY_ASSET,
                 .DEACTIVATE_BEACON:
                    return .write
        }
    }
}