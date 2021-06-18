import SwiftUI

// Views:  
//    1. Feed list view
//       - (Image)   |name|url|unread cnt|
//       - Swipe to toggle all items unread status?
//       - Search field
//       - Reload button ( GET /reload && GET /feeds ) -> Enter loading view
//    2. Item list view
//       - (Image)   |title with link|pubdate
//       - Swipe to toggle unread status
//       - Fetch video thumbnails for the images

struct SearchView: View {

   var barWidth: CGFloat;
   @Binding var searchBinding: String;

   var body: some View {
      HStack (alignment: .center, spacing: 5){
         Image(systemName: "magnifyingglass")
         TextField("Search...", text: $searchBinding)
            .padding(10)
            .background(Color.black.opacity(0.2))
            .cornerRadius(5)
            .frame(
               width: self.barWidth, 
               height: ROW_HEIGHT, 
               alignment: .center
           )
      }
   }
}

struct RssFeedRowView: View {

   var feed: RssFeed;
   var screenWidth: CGFloat;

   var body: some View {
      // | 50px | 0.5 %      | 0.5 % - 50px |
      HStack {
         NavigationLink(destination: SettingsView() ){
            Image("umbreon")
               .resizable() // Must be applied before modifying the frame size
               .clipShape(Circle())
               .frame(
                  width: IMAGE_WIDTH,  
                  height: ROW_HEIGHT, 
                  alignment: .center
            )
            .padding(.leading, 5)
         }

         VStack (alignment: .leading, spacing: 5){
            NavigationLink(destination: SettingsView() ){
               Text("\(feed.title)")
                  .foregroundColor(.white)
                  .font(.system(size:22,weight: .bold))
                  .lineLimit(1)
            }
            Link("\(URL(string: feed.url)?.host ?? "???")", destination: URL(string: feed.url)! )
               .foregroundColor(.blue)
               .font(.system(size:18))
               .lineLimit(1)
         }
         // This is required for the elements in the stack to actually
         // "float" to the left
         .frame(
            width: self.screenWidth * 0.5, 
            alignment: .leading
         )
         
         
         Text( "\(feed.unread_count)/\(feed.item_count)" )
            .padding(7)
            .background(Color.black.opacity(0.2))
            .cornerRadius(5)
            .foregroundColor(.white)
            .font(Font.system(size:18, weight: .bold))
            .frame(
               // The image leads with 5px of padding
               width: self.screenWidth * 0.5  - (IMAGE_WIDTH+5), 
               alignment: Alignment.center
            )
            .lineLimit(1) 
      }
      .padding(.bottom, 5)

   }
}

struct FeedsView: View {

   //@EnvironmentObject var env: GlobalState;
   @State var isLoading: Bool = true;

   @State var feeds = [RssFeed]();
   
   @State var searchString: String = "";

   @State var showAlert: Bool = false;
   @State var alertMessage: String = "";
   @State var alertTitle: String = "";

   init?() {
      // https://stackoverflow.com/questions/57128547/swiftui-list-color-background
      UITableView.appearance().backgroundColor = .clear
      UITableViewCell.appearance().backgroundColor = .clear
      
      // https://stackoverflow.com/a/58974331/9033629 
      UINavigationBar.appearance().barTintColor = .clear
      UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
   }
   
   func makeAlert(title: String, err: Error?) {
      self.alertTitle = title; 
      self.alertMessage = "\(err?.localizedDescription ?? "Unknown error")";
      self.showAlert = true;
      NSLog("\(title): \(self.alertMessage)");
   }

   /// Fetch a list of all entries from the provided path
   /// on the remote server
   func loadFeeds() -> Void {
      
      guard let url = URL(string: "http://10.0.1.30:5000/feeds") else { return } 
      var req = URLRequest(url: url);
      req.addValue("test", forHTTPHeaderField: "x-creds")

      URLSession.shared.dataTask(with: req) { data, response, err in
         // Create a background task to fetch data from the server
         if data != nil {
            do { 
               
               let decoded = try JSONDecoder().decode([RssFeed].self, from: data!) 
               // If the response data was successfully decoded dispatch an update in the
               // main thread (all UI updates should be done in the main thread)
               // to update the state in the view
               DispatchQueue.main.async {
                  self.feeds = decoded;
                  self.isLoading = false;
               }
            }
            catch { 
               makeAlert(title: "Decoding error", err: err); 
               self.isLoading = false;
            }
         }
         else { 
            makeAlert(title: "Connection error", err: err) 
            self.isLoading = false;
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
                  .animation(nil)
               
      if self.isLoading {
         LoadingView(width: geometry.size.width, height: geometry.size.height,  loadingText:"Loading...")
      .onAppear(perform: loadFeeds)
      }
      else {
               
               ScrollView(.vertical) { 
                  // The alignment parameter for a VStack concerns horizontal alignment
                  VStack(alignment: .center, spacing: 0) {
                     
                     HStack(alignment: .top) {
                        SearchView( barWidth: geometry.size.width * 0.6, searchBinding: $searchString )
                           .padding(.bottom, 20)
                        
                        // Settings and reload buttons
                        NavigationLink(destination: SettingsView() ){
                           Image(systemName: "slider.horizontal.3").resizable().frame(
                              width: 25, height: 25, alignment: .center
                           )
                        }
                        .padding(10)
                        Button(action: {
                           NSLog("Reload!")
                        }) {
                           Image(systemName: "arrow.clockwise").resizable().frame(
                              width: 25, height: 25, alignment: .center
                           )
                        }
                        .padding(10)
                     }


                     ForEach(feeds, id: \.id ) { feed in
                        // We need the entry class to have an ID
                        // to iterate over it using ForEach()
                     
                        if feed.title.contains(searchString) || searchString == "" {
                           RssFeedRowView(feed: feed, screenWidth: geometry.size.width)
                        }
                     }
                     
                     //if self.isLoading {
                     //   ZStack(alignment: .center) {
                     //      ProgressView()
                     //         .progressViewStyle(CircularProgressViewStyle(tint: .white) )
                     //         .scaleEffect(s: CGFloat, anchor: UnitPoint)
                     //         .position(
                     //            x: geometry.size.width/2 - 60, 
                     //            y: geometry.size.height/2 - 60
                     //         )
                     //   }
                     //}
                     
                     
                  }
                  .listRowBackground(Color.clear)
                  //.onAppear(perform: loadFeeds)
                  .alert(isPresented: self.$showAlert) {
                     Alert(
                        title: Text(self.alertTitle), 
                        message: Text(self.alertMessage), 
                        dismissButton: .default(Text("OK"))
                     )
                  }
               }
            }
         
         }
            
         }

      }
   }

