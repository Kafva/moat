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

//private extension FeedsView {
//   struct SearchView: View {
//
//      var barWidth: CGFloat;
//      var searchString: String;
//
//      var body: some View {
//         HStack (alignment: .center, spacing: 5){
//            Image(systemName: "magnifyingglass")
//            TextField("Search...", text: searchString)
//               .padding(10)
//               .background(Color.black.opacity(0.2))
//               .cornerRadius(5)
//               .frame(
//                  width: self.barWidth, 
//                  height: ROW_HEIGHT, 
//                  alignment: .center
//              )
//         }
//      }
//   }
//}

struct FeedsView: View {

   @State var feeds = [RssFeed]();
   
   @State var searchString = "";

   init?() {
      // https://stackoverflow.com/questions/57128547/swiftui-list-color-background
      UITableView.appearance().backgroundColor = .clear
      UITableViewCell.appearance().backgroundColor = .clear
      
      // https://stackoverflow.com/a/58974331/9033629 
      UINavigationBar.appearance().barTintColor = .clear
      UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
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
               }
            }
            catch { NSLog("Decoding failure \(error)"); }
         }
         else {
            NSLog("Error fetching data: \(err?.localizedDescription ?? "Unknown error")");
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
            
            ScrollView(.vertical) { 
               // The alignment parameter for a VStack concerns horizontal alignment
               VStack(alignment: .center, spacing: 0) {
                  
                  HStack (alignment: .center, spacing: 5){
                     Image(systemName: "magnifyingglass")
                     TextField("Search...", text: searchString)
                        .padding(10)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(5)
                        .frame(
                           width: geometry.size.width * 0.7, 
                           height: ROW_HEIGHT, 
                           alignment: .center
                       )
                  }

                  ForEach(feeds, id: \.id ) { feed in
                     // We need the entry class to have an ID
                     // to iterate over it using ForEach()
                  
                     if feed.title.contains(searchString) || searchString == "" {
                        
                        // | 50px | 0.7 %      | 0.3 % - 50px |
                        HStack {
                           NavigationLink(destination: LoadingView("YEP") ){
                              Image("umbreon")
                                 .resizable() // Must be applied before modifying the frame size
                                 .clipShape(Circle())
                                 .frame(
                                    width: IMAGE_WIDTH,  
                                    height: ROW_HEIGHT, 
                                    alignment: .center
                              )
                           }

                           VStack (alignment: .leading, spacing: 5){
                              NavigationLink(destination: LoadingView("YEP") ){
                                 Text("\(feed.title)")
                                    .foregroundColor(.white)
                                    .font(.system(size:22))
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                              }
                              Link("Site", destination: URL(string: feed.url)! )
                                 .foregroundColor(.blue)
                                 .font(.system(size:18))
                                 .lineLimit(1)
                           }
                           // This is required for the elements in the stack to actually
                           // "float" to the left
                           .frame(
                              width: geometry.size.width * 0.65, 
                              alignment: .leading
                           )
                           
                           
                           Text( "\(feed.unread_count)/\(feed.item_count)" )
                              .background(Color.black.opacity(0.2))
                              .cornerRadius(5)
                              .foregroundColor(.white)
                              .font(.system(size:18))
                              .fontWeight(.bold)
                              .frame(
                                 width: geometry.size.width * 0.35  - IMAGE_WIDTH, 
                                 alignment: .leading
                              )
                              .lineLimit(1) 
                        }
                        .padding(10)
                     }
                  }
               }
               .listRowBackground(Color.clear)
               .onAppear(perform: loadFeeds)
            }
         }
      
      }

   }
}
