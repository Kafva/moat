import SwiftUI

class ServerResponse: Codable {
    let success: Bool
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case success
        case message
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.success, forKey: .success)
        try container.encodeIfPresent(self.message, forKey: .message)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try values.decode(Bool.self, forKey: .success)
        self.message = try values.decodeIfPresent(String.self, forKey: .message)
    }

    init(success: Bool, message: String?) {
        self.success = success
        self.message = message
    }
}
