import SwiftUI
import SwiftyXMLParser

class ApiWrapper<T: Codable> {
  
  /// Fetch a list of all feeds or all items for a perticular feed
  /// The arbitrary type needs to implemennt the codable protocol
  func loadRows(rows: ObservableArray<T>, alert: AlertState, isLoading: Binding<Bool>, rssurl: String = "") -> Void {
     
      guard let serverLocation = UserDefaults.standard.string(forKey: "serverLocation") else {
         alert.makeAlert(
            title: "Incomplete configuration", 
            err: ServerConnectionError.noServerLocation, 
            isLoading: isLoading
         ) 
         return
      }
      guard let serverKey = UserDefaults.standard.string(forKey: "serverKey") else {
         alert.makeAlert(
            title: "Incomplete configuration", 
            err: ServerConnectionError.noServerKey, 
            isLoading: isLoading
         ) 
         return
      }
      var api_url = "http://\(serverLocation)/feeds"
      
      if T.self is RssItem.Type {
         api_url = "http://\(serverLocation)/items/\(rssurl.toBase64())"
      }

      guard let url = URL(string: api_url) else { return } 
      var req = URLRequest(url: url);
      req.addValue(serverKey, forHTTPHeaderField: "x-creds")

       URLSession.shared.dataTask(with: req) { data, res, err in
         // Create a background task to fetch data from the server

         if (res as? HTTPURLResponse)?.statusCode == 401 {
            alert.makeAlert(
               title: "Unauthorized", 
               err: ServerConnectionError.invalidKey, 
               isLoading: isLoading
            ); 
         } 
         else {
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
      }
      .resume(); // Execute the task immediatelly
  }
}

