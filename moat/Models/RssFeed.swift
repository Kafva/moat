import SwiftUI

class RssFeed: ObservableObject, Codable, Equatable {
    // The codable property enables a struct to be
    // serialised/deserialised
    // https://www.hackingwithswift.com/swift4
    // https://www.hackingwithswift.com/books/ios-swiftui/sending-and-receiving-codable-data-with-urlsession-and-swiftui
    @Published var unread_count: Int
    let rssurl: String
    let url: String
    let title: String
    var item_count: Int
    let id = UUID()  // client-side only attribute
    let muted: Bool

    /// Returns true if the provided feeds have the same
    /// properties, ignores differences in the `id` property
    public static func == (lhs: RssFeed, rhs: RssFeed) -> Bool {
        return lhs.rssurl == rhs.rssurl && lhs.url == rhs.url
            && lhs.title == rhs.title && lhs.unread_count == rhs.unread_count
            && lhs.item_count == rhs.item_count
    }

    private enum CodingKeys: String, CodingKey {
        // An enum which impllements the CodingKey protocol can be used to
        // map different JSON keys to different attributes in a codable object
        // i.e. a key-name could be mapped to an internal attribute named something else
        case rssurl
        case url
        case title
        case unread_count
        case item_count = "total_count"
        case muted
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.rssurl, forKey: .rssurl)
        try container.encode(self.url, forKey: .url)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.unread_count, forKey: .unread_count)
        try container.encode(self.item_count, forKey: .item_count)
        try container.encode(self.muted, forKey: .muted)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.rssurl = try values.decode(String.self, forKey: .rssurl)
        self.url = try values.decode(String.self, forKey: .url)
        self.title = try values.decode(String.self, forKey: .title)
        self.unread_count = try values.decode(Int.self, forKey: .unread_count)
        self.item_count = try values.decode(Int.self, forKey: .item_count)
        self.muted = try values.decode(Bool.self, forKey: .muted)
    }

    init(
        rssurl: String, url: String, title: String, unread_count: Int,
        item_count: Int, muted: Bool
    ) {
        self.rssurl = rssurl
        self.url = url
        self.title = title
        self.unread_count = unread_count
        self.item_count = item_count
        self.muted = muted
    }

    func getChannelId() -> String? {
        // If the feed is a YouTube channel on the form
        //  https://www.youtube.com/feeds/videos.xml?channel_id=<...>
        // return the video ID
        guard let url_params = URL(string: self.rssurl)?.query else {
            return nil
        }

        let components = url_params.components(separatedBy: "=")

        if components.first == "channel_id" && components.count == 2 {
            return components[1]
        } else {
            return nil
        }
    }
}
