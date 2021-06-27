import SwiftUI

class ApiWrapper<T: Codable> {
  
  private func getServerConfig(alert: AlertState, isLoading: Binding<Bool>?) -> (String, String)? {
      guard let serverLocation = UserDefaults.standard.string(forKey: "serverLocation") else {
         alert.makeAlert(
            title: "Incomplete configuration", 
            err: ServerConnectionError.noServerLocation, 
            isLoading: isLoading
         ) 
         return nil
      }
      guard let serverKey = UserDefaults.standard.string(forKey: "serverKey") else {
         alert.makeAlert(
            title: "Incomplete configuration", 
            err: ServerConnectionError.noServerKey, 
            isLoading: isLoading
         ) 
         return nil
      }
      
      return (serverLocation, serverKey)
  
  }
  
  /// Fetch a list of all feeds or all items for a perticular feed
  /// The arbitrary type needs to implemennt the codable protocol
  func loadRows(rows: ObservableArray<T>, alert: AlertState, isLoading: Binding<Bool>, rssurl: String = "") -> Void {
     
      guard let (serverLocation, serverKey) = 
         self.getServerConfig(alert: alert, isLoading: isLoading) 
      else { return }

      var api_url = "http://\(serverLocation)/feeds"
      
      if T.self is RssItem.Type {
         api_url = "http://\(serverLocation)/items/\(rssurl.toBase64())"
      }

      guard let url = URL(string: api_url) else { return } 
      var req = URLRequest(url: url, timeoutInterval: SERVER_REQUEST_TIMEOUT);
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
  
  func setAllItemsAsRead(unread_count: Binding<Int>, rssurl: String, alert: AlertState) -> Void {
      guard let (serverLocation, serverKey) = 
         self.getServerConfig(alert: alert, isLoading: nil) 
      else { return }
      
      let api_url = "http://\(serverLocation)/unread"

      guard let url = URL(string: api_url) else { return } 
      var req = URLRequest(url: url, timeoutInterval: SERVER_REQUEST_TIMEOUT);
      req.addValue(serverKey, forHTTPHeaderField: "x-creds")
      
      // Add POST data
      req.httpMethod = "POST"
      req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
      req.httpBody = "rssurl=\(rssurl)&unread=false".data(using: .ascii)

      URLSession.shared.dataTask(with: req) { data, res, err in
         if (res as? HTTPURLResponse)?.statusCode == 401 {
            alert.makeAlert(
               title: "Unauthorized", 
               err: ServerConnectionError.invalidKey, 
               isLoading: nil
            ); 
         } 
         else {
            if data != nil {
             do { 
               
               let decoded = try JSONDecoder().decode(ServerResponse.self, from: data!); 

               // If the response data was successfully decoded dispatch an update in the
               // main thread (all UI updates should be done in the main thread)
               // to update the state in the view
               DispatchQueue.main.async {
                  if !decoded.success {
                     alert.makeAlert(
                        title: "Bad request", 
                        err: ServerConnectionError.unexpected(code: 400) , 
                        isLoading: nil
                     )
                  }
                  else  {
                     // Update the binding to the unread_count value for the
                     // RssFeedRow in question
                     unread_count.wrappedValue = 0
                  }
               }
             }
             catch { 
               alert.makeAlert(
                  title: "Decoding error", err: err, isLoading: nil
               ); 
             }
            }
            else { 
               alert.makeAlert(
                  title: "Connection error", err: err, isLoading: nil
               ); 
            }
         }
      }
      .resume(); // Execute the task immediatelly

   }
  
  func setUnreadStatus(unread_count: Binding<Int>, unread_binding: Binding<Bool>, rssurl: String, video_id: Int, alert: AlertState) -> Void {
     
      guard let (serverLocation, serverKey) = 
         self.getServerConfig(alert: alert, isLoading: nil) 
      else { return }
      
      if video_id == 0 && rssurl == "" {
         print("setUnreadStatus() requires either a `video_id` or `rssurl` argument")
         return
      }

      let api_url = "http://\(serverLocation)/unread"

      guard let url = URL(string: api_url) else { return } 
      var req = URLRequest(url: url, timeoutInterval: SERVER_REQUEST_TIMEOUT);
      req.addValue(serverKey, forHTTPHeaderField: "x-creds")
      
      // The value for the unread parameter will be the opposite of the current value
      let unread = !unread_binding.wrappedValue ? "true" : "false";

      // Add POST data
      req.httpMethod = "POST"
      req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
      req.httpBody = "id=\(video_id)&unread=\(unread)".data(using: .ascii)


      URLSession.shared.dataTask(with: req) { data, res, err in
         if (res as? HTTPURLResponse)?.statusCode == 401 {
            alert.makeAlert(
               title: "Unauthorized", 
               err: ServerConnectionError.invalidKey, 
               isLoading: nil
            ); 
         } 
         else {
            if data != nil {
             do { 
               
               let decoded = try JSONDecoder().decode(ServerResponse.self, from: data!); 

               // If the response data was successfully decoded dispatch an update in the
               // main thread (all UI updates should be done in the main thread)
               // to update the state in the view
               DispatchQueue.main.async {
                  if !decoded.success {
                     alert.makeAlert(
                        title: "Bad request", 
                        err: ServerConnectionError.unexpected(code: 400) , 
                        isLoading: nil
                     )
                  }
                  else  {
                     // Update the binding to the unread_count value in the FeedsView
                     // and toggle the boolean value for the ItemsView
                     unread_count.wrappedValue += unread_binding.wrappedValue ? -1 : 1 
                     unread_binding.wrappedValue = !unread_binding.wrappedValue
                  }
               }
             }
             catch { 
               alert.makeAlert(
                  title: "Decoding error", err: err, isLoading: nil
               ); 
             }
            }
            else { 
               alert.makeAlert(
                  title: "Connection error", err: err, isLoading: nil
               ); 
            }
         }
      }
      .resume(); // Execute the task immediatelly

   }
}

