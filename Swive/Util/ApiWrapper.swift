import SwiftUI
import SwiftyXMLParser

class ApiWrapper<T: Codable> {
  
  /// Fetch a list of all feeds or all items for a perticular feed
  /// The arbitrary type needs to implemennt the codable protocol
  func loadRows(
    rows: ObservableArray<T>,  
    alert: AlertState,
    isLoading: Binding<Bool>,
    rssurl: String = ""
   ) -> Void {
     
      var api_url = "http://10.0.1.30:5000/feeds"
      
      if T.self is RssItem.Type {
         api_url = "http://10.0.1.30:5000/items/\(rssurl.toBase64())"
      }

      guard let url = URL(string: api_url) else { return } 
      var req = URLRequest(url: url);
      req.addValue("test", forHTTPHeaderField: "x-creds")

       URLSession.shared.dataTask(with: req) { data, response, err in
         // Create a background task to fetch data from the server
         if data != nil {
          do { 
            let decoded = try JSONDecoder().decode([T].self, from: data!); 

            // If the response data was successfully decoded dispatch an update in the
            // main thread (all UI updates should be done in the main thread)
            // to update the state in the view
            DispatchQueue.main.async {
              rows.arr = decoded;
              isLoading.wrappedValue = false;
            }
          }
          catch { 
            alert.makeAlert(
               title: "Decoding error", err: err, isLoading: isLoading
            ); 
          }
         }
         else { 
            alert.makeAlert(
               title: "Connection error", err: err, isLoading: isLoading
            ); 
         }
      }
      .resume(); // Execute the task immediatelly
  }
  


   // One could make a /thumb/<item-id> endpoint and relied
   // completly on the server to fetch images. This would give
   // better performance since the server usually has a better connenction
   // than the client. It would however require the server to fetch
   // the XML for each feed for every image, this request should definitly
   // be cached unless it isn't automatically

   //func getThumbnailUrls(
   //  image_urls: ObservableArray<String>,
   //  rssurl: String,
   //  alert: AlertState,
   //  isLoading: Binding<Bool>
   // ) -> Void {
   //   
   //   guard let url = URL(string: rssurl) else { return } 
   //   let req = URLRequest(url: url);
   //
   //    URLSession.shared.dataTask(with: req) { data, response, err in
   //    
   //       if data != nil {
   //        do { 
   //            let xml = try XML.parse(
   //               String(bytes: data!, encoding: .utf8)!
   //            )
   //            var index = 0;

   //            while let image_url = 
   //               xml["feed", "entry", index, "media:group", "media:thumbnail"].attributes["url"] {

   //               image_urls.arr.append(image_url)
   //               index += 1
   //            } 
   //        }
   //        catch { 
   //          alert.makeAlert(
   //             title: "Decoding error", err: err, isLoading: isLoading
   //          ); 
   //        }
   //       }
   //       else { 
   //          alert.makeAlert(
   //             title: "Connection error", err: err, isLoading: isLoading
   //          ); 
   //       }
   //     }
   //     .resume(); // Execute the task immediatelly
   //}

}

