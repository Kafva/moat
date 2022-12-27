import SwiftUI

class RssItem: ObservableObject, Codable {
   let id: Int
   let title: String
   let author: String
   let url: String
   let pubdate: Int
   var unread: Bool

   private enum CodingKeys: String, CodingKey {
        case id
        case title
        case author
        case url
        case pubdate
        case unread
   }

   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(self.id, forKey: .id)
      try container.encode(self.title, forKey: .title)
      try container.encode(self.author, forKey: .author)
      try container.encode(self.url, forKey: .url)
      try container.encode(self.pubdate, forKey: .pubdate)
      try container.encode(self.unread, forKey: .unread)
   }

   required init(from decoder: Decoder ) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)

      self.id = try values.decode(Int.self, forKey: .id)
      self.title = try values.decode(String.self, forKey: .title)
      self.author = try values.decode(String.self, forKey: .author)
      self.url = try values.decode(String.self, forKey: .url)
      self.pubdate = try values.decode(Int.self, forKey: .pubdate)
      self.unread = try values.decode(Bool.self, forKey: .unread)
   }

   init(id: Int, title: String, author: String, url: String, pubdate: Int, unread: Bool) {
      self.id = id;
      self.title = title;
      self.author = author;
      self.url = url;
      self.pubdate = pubdate;
      self.unread = unread;
   }

   func DateText() -> Text {
      let fmt = DateFormatter()
      fmt.dateStyle = .short
      fmt.timeStyle = .none

      return Text( Date(
         timeIntervalSince1970: Double(self.pubdate)),
         formatter: fmt
      )
   }

   func getVideoId() -> String? {
      // If the item is a YouTube video on the form
      //   https://www.youtube.com/watch?v=GGGGGGGGGGG
      // return the video ID
      guard let url_params = URL(string: self.url)?.query else {
         return nil
      }

      let components = url_params.components(separatedBy: "=");

      if components.first == "v" && components.count == 2  {
         return components[1]
      }
      else { return nil }
   }
}
