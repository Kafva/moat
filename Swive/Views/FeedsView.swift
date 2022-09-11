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

   @StateObject var feeds: ObservableArray<RssFeed> = ObservableArray();
   @StateObject var alertState: AlertState = AlertState();
   
   @State var isLoading: Bool = true;
   @State var searchString: String = "";
   //@State var loadingText: String = "Loading..."

   var apiWrapper = ApiWrapper<RssFeed>()

   init?() {
      setViewTransparency()
   }
   
   var body: some View {
         GeometryReader { geometry in 
            // Gain access to the screen dimensions to perform proper sizing
            if self.isLoading {
               ZStack {
                   LoadingView(
                      //loadingText: $loadingText, 
                      sceneSize: CGSize(
                         width: geometry.size.width, 
                         height: geometry.size.height
                      )
                   )
                   .onAppear(perform: {
                      self.apiWrapper.loadRows(
                         rows: feeds, 
                         alert: alertState, 
                         isLoading: $isLoading
                      )} 
                   )
                   
                   LoadingTextView()
               }
            }
            else {
               ScrollView(.vertical) { 
                  // The alignment parameter for a VStack concerns horizontal alignment
                  VStack(alignment: .center, spacing: 0) {
                     
                     ActionBarView(
                        searchString: $searchString, 
                        searchBarWidth: geometry.size.width * 0.6
                     )
                     // When the rows are not loaded we need to add additional padding for the items in the bar 
                     .padding(.leading,  feeds.arr.count == 0 ? 15 : 0 )
                     .environmentObject(feeds) // Passed onward to SettingsView

                     ForEach(feeds.arr, id: \.id ) { feed in
                        // We need the entry class to have an ID
                        // to iterate over it using ForEach()
                     
                        if feed.title.contains(searchString) || searchString == "" {
                           RssFeedRowView(feed: feed, screenWidth: geometry.size.width)
                        }
                     }
                  }
                  .listRowBackground(Color.clear)
               }
            }
         }
         .alert(isPresented: $alertState.show ) {
            Alert(
               title: Text(alertState.title), 
               message: Text(alertState.message), 
               dismissButton: .default(Text("OK"))
         )
      }
   }
}

