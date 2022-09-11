import SwiftUI

struct ItemsView: View {

   var feedurl: String = "" 
   @State var items: [RssItem] = [];
   //@Binding var items;
   
   @State var isLoading: Bool = true;

   // Alerts
   @State var showAlert: Bool = false;
   @State var alertMessage: String = "";
   @State var alertTitle: String = "";

   init?(_ feedurl: String) {
      // https://stackoverflow.com/questions/57128547/swiftui-list-color-background
      UITableView.appearance().backgroundColor = .clear
      UITableViewCell.appearance().backgroundColor = .clear
      
      // https://stackoverflow.com/a/58974331/9033629 
      UINavigationBar.appearance().barTintColor = .clear
      UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
      
      self.feedurl = feedurl;
   }
   
   func makeAlert(title: String, err: Error?) {
      self.alertTitle = title; 
      self.alertMessage = "\(err?.localizedDescription ?? "No description available")";
      self.showAlert = true;
      NSLog("\(title): \(self.alertMessage)");
      self.isLoading = false;
   }

   /// Fetch a list of all entries from the provided path
   /// on the remote server
   func loadItems() -> Void {
      
      guard let url = URL(string: "http://10.0.1.30:5000/items/\(self.feedurl)") else { return } 
      var req = URLRequest(url: url);
      req.addValue("test", forHTTPHeaderField: "x-creds")

      URLSession.shared.dataTask(with: req) { data, response, err in
         // Create a background task to fetch data from the server
         if data != nil {
            do { 
               
               let decoded = try JSONDecoder().decode([RssItem].self, from: data!) 
               // If the response data was successfully decoded dispatch an update in the
               // main thread (all UI updates should be done in the main thread)
               // to update the state in the view
               DispatchQueue.main.async {
                  self.items = decoded;
                  self.isLoading = false;
               }
            }
            catch { 
               makeAlert(title: "Decoding error", err: err); 
            }
         }
         else { 
            makeAlert(title: "Connection error", err: err) 
         }
      }.resume(); // Execute the task immediatelly
   }

    var body: some View {
        GeometryReader { geometry in 
            // Gain access to the screen dimensions to perform proper sizing
            ZStack {
               // The Gradient background needs to be placed inside the ZStack to appear beneath
               // the scene (which we give a transparent background)
               
               BKG_GRADIENT_LINEAR
                  .edgesIgnoringSafeArea(.vertical) // Fill entire screen 
               
               if self.isLoading {
                  LoadingView(
                     width: geometry.size.width, 
                     height: geometry.size.height,  
                     loadingText:"Loading..."
                  )
                  .onAppear(perform: loadItems)
                }
                else {
                  ScrollView(.vertical) { 
                    // The alignment parameter for a VStack concerns horizontal alignment
                    VStack(alignment: .center, spacing: 0) {
                       
                       HStack(alignment: .top) {

                       ForEach(self.items, id: \.id ) { item in
                           Text(item.title)
                       }
                    }
                    .listRowBackground(Color.clear)
                    .alert(isPresented: self.$showAlert) {
                       Alert(
                          title: Text(self.alertTitle), 
                          message: Text(self.alertMessage), 
                          dismissButton: .default(Text("OK"))
                       )}
                    }
                }
            }
        }
    }
    }
}

