import SwiftUI

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
}

