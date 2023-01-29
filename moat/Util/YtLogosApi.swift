import SwiftUI

func getLogoUrl(channelId: String, name: String,  completion: @escaping (String) -> Void ) {
  let channel_url = URL(string: "https://www.youtube.com/channel/\(channelId)/about")!

  // To bypass the consent screen we need to inject a cookie into the request
  if let cookie = HTTPCookie(properties: [
    .domain: ".youtube.com",
    .path: "/",
    .name: "CONSENT",
    .value: "YES+cb.20210615-14-p0.en-GB+FX+503",
    .secure: "TRUE",
  ]) {
    // Note that we use both the 'shared' session and cookie storage
    HTTPCookieStorage.shared.setCookie(cookie)
  }

  let req = URLRequest(url: channel_url)

  URLSession.shared.dataTask(with: req) { data, _, _ in
      if let data = data {
        completion(
          extractLogoUrl( String(decoding: data, as: UTF8.self), name: name ) ?? ""
        )
      }
  }.resume()
}

/// Patterns:
///   https://yt3.ggpht.com/ytc/AAUvwniD_RGcy5bq8EqWUnk8wHzafZo4w8ZJfNU-QWLUzg=s300-c-k-c0x00ffffff-no-rj
///   https://yt3.ggpht.com/B3TFzvwt8Abuk3xweJvBLcL5Xt3Y7TatvDyWDtsEoR3A4oZkTA4ajbz_yRo2QF70WYDpb9k=s88-c-k-c0x00ffffff-no-rj
///
/// Update (Jan 29 2023)
///   https://yt3.ggpht.com/ -> https://yt3.googleusercontent.com/
func extractLogoUrl(_ htmlBody: String, name: String ) -> String? {
  if htmlBody.matches("Before you continue to YouTube").first != nil {
    print("Failed to fetch YouTube logo for \(name): Blocked by consent screen")
    return ""
  }
  if let logo = htmlBody.matches("https://yt3.googleusercontent.com(/ytc)?/[-=+_A-Za-z0-9]{10,255}-no-rj").first {
    return logo
  }  else {
    print("Failed to fetch YouTube logo for \(name)")
    return ""
  }
}

/// Channel logos do not have a fully predictable format but we can save them by
/// first issuing a query to a channel's about page and matching agianst the general pattern
///   https://yt3.ggpht.com/ytc/AAUvwniD_RGcy5bq8EqWUnk8wHzafZo4w8ZJfNU-QWLUzg=s300-c-k-c0x00ffffff-no-rj
/// We will store these urls in a dict inside UserDefaults à la
/// [ "channelId": <logo url>, ...]
func setLogosInUserDefaults(feeds: [RssFeed], finishedCount: Binding<Int>, completion: @escaping ([String: String]) -> Void ) {
  // Always start from an empty dict instead of fetching any potential previous version
  var logos =  [String: String]()

  finishedCount.wrappedValue=0;

  for feed in feeds {

    guard let channelId = feed.getChannelId() else {
      print("Skipping logo fetch for \(feed.title)")

      finishedCount.wrappedValue+=1;

      if finishedCount.wrappedValue == feeds.count {
        completion(logos)
      }
      continue
    }

    getLogoUrl(channelId: channelId, name: feed.title, completion: { logoUrl in
      logos[channelId] = logoUrl

      finishedCount.wrappedValue+=1;

      if finishedCount.wrappedValue == feeds.count {
        completion(logos)
      }
    })
  }
}

func getLogoUrlFromUserDefaults(channelId: String) -> String? {
  let logos = UserDefaults.standard.object(forKey: "logos")
    as? [String: String] ?? [String: String]()

  return logos[channelId]
}
