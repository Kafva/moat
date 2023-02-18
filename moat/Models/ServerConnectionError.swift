import SwiftUI

enum ServerConnectionError: Error, LocalizedError {
    case noServerLocation
    case noServerPort
    case invalidKey
    case noServerKey
    case feedReloadFailure
    case unexpected(code: Int)

    // The error description will be shown when a `throw` occurs
    // and is required by the LocalizedError protocol
    public var errorDescription: String? {
        switch self {
        case .noServerLocation:
            return NSLocalizedString(
                "No server location has been configured", comment: "")
        case .noServerPort:
            return NSLocalizedString(
                "No server port has been configured", comment: "")
        case .noServerKey:
            return NSLocalizedString(
                "No server key has been configured", comment: "")
        case .invalidKey:
            return NSLocalizedString("Invalid server key", comment: "")
        case .feedReloadFailure:
            return NSLocalizedString("Failed to reload feeds", comment: "")
        case .unexpected(_):
            return NSLocalizedString("Unexpected error", comment: "")
        }
    }
}
