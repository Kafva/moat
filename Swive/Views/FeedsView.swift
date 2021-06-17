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
                     TextField("Search...", text: $searchString)
                           .padding(10)
                           .background(Color.black.opacity(0.2))
                           .cornerRadius(5)
                           .frame(
                              minWidth: 50, idealWidth: 200, maxWidth: 250, 
                              minHeight: 50, idealHeight: 50, maxHeight: 50, 
                              alignment: .center
                           )
                           //.shadow(color: .gray, radius: 10)
                  }

                  ForEach(feeds, id: \.id ) { feed in
                     // We need the entry class to have an ID
                     // to iterate over it using ForEach()
                  
                     if feed.title.contains(searchString) || searchString == "" {
                        NavigationLink(destination: LoadingView("YEP") ){
                              HStack(alignment: .firstTextBaseline) {
                                 Image("umbreon")
                                    .resizable() // Must be applied before modifying the frame size
                                    .clipShape(Circle())
                                    .frame(width: 50, height: 50, alignment: .center)

                                 VStack {
                                    Text("\(feed.title)")
                                       .foregroundColor(.white)
                                       .font(.system(size:17))
                                       .fontWeight(.bold)
                                    Link("Site", destination: URL(string: feed.url)! )
                                       .foregroundColor(.blue)
                                       .font(.system(size:12))
                                 }
                                 .frame(maxWidth: .infinity)
                                 
                                 Text( "\(feed.unread)/90" )
                                    .frame(maxWidth: .infinity)
                           }
                           .padding(10)
                        }
                     }
                  }
               }
               .listRowBackground(Color.clear)
               .onAppear(perform: loadFeeds)
            }
      }
   }
}
