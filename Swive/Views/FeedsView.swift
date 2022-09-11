import SwiftUI

struct FeedsView: View {

   @StateObject var feeds: ObservableArray<RssFeed> = ObservableArray();
   @StateObject var alertState: AlertState = AlertState();
   
   @State var isLoading: Bool = true;
   @State var searchString: String = "";

   /// Computed property to determine if the current query yields no results
   var noMatches: Bool { 
      !feeds.arr.contains(where: { feed in  feed.title.contains(searchString) } ) && searchString != ""
   }
   
   var apiWrapper       = ApiWrapper<RssFeed>()

   init?() {
      setViewTransparency()
   }
   
   var body: some View {
         GeometryReader { geometry in 
            // Gain access to the screen dimensions to perform proper sizing
            if self.isLoading {
                  if UserDefaults.standard.bool(forKey: "spritesOn") {
                     LoadingView(
                        active: $isLoading,
                        sceneSize: CGSize(
                           width: geometry.size.width, 
                           height: geometry.size.height
                        )
                     )
                     .onDisappear(perform: {
                        // isLoading = false
                        print("Leaving loading view")
                     })
                  }

                  LoadingTextView()
                     .onAppear(perform: {
                        self.apiWrapper.loadRows(
                           rows: feeds, 
                           alert: alertState, 
                           isLoading: $isLoading
                        )} 
                  )
                  // Neccessary for correct positioning when
                  // the LoadingView isn't active
                  .frame(
                     width: geometry.size.width, 
                     height: geometry.size.height, 
                     alignment: .center
                  )
            }
            else {
               ScrollView(.vertical) { 
                  // The alignment parameter for a VStack concerns horizontal alignment
                  VStack(alignment: .center, spacing: 0) {
                     
                     ActionBarView(
                        searchString: $searchString, 
                        isLoading: $isLoading,
                        searchBarWidth: geometry.size.width * 0.6
                     )
                     // Its not possible to have a selection based on the feeds.arr length, all items
                     // are always loaded after the loadRows call
                     .padding(.leading, noMatches ? 15+10 : 15)
                     .padding(.trailing, noMatches ? 0 : 15)
                     .frame(alignment: .center)
                     .environmentObject(feeds) // Passed onward to SettingsView
                     .environmentObject(alertState)
                     // Note that we cannot mount more than one alert in the same 
                     // parent-child hierachy for a view and since each `RssFeedRow` has its own alert 
                     // we thus can't place this alert around the entire body
                     .alert(isPresented: $alertState.show ) {
                        Alert(
                           title: Text(alertState.title), 
                           message: Text(alertState.message), 
                           dismissButton: .default(Text("OK"))
                        )
                     }
                     
                     ForEach(feeds.arr, id: \.id ) { feed in
                        // We need the entry class to have an ID
                        // to iterate over it using ForEach()
                     
                        if feed.title.contains(searchString) || searchString == "" {
                           RssFeedRowView(feed: feed, screenWidth: geometry.size.width) 
                        }
                     }
                     
                     if noMatches {
                        Text("No matches")
                           .padding(7)
                           .background(Color.black.opacity(0.2))
                           .cornerRadius(5)
                           .foregroundColor(.white)
                           .font(Font.system(size:18, weight: .bold))
                           .frame(
                              // The image leads with 5px of padding
                              width: geometry.size.width * 0.5  - (IMAGE_WIDTH+5), 
                              alignment: Alignment.center
                           )
                           .lineLimit(1) 
                     }
                  }
                  .listRowBackground(Color.clear)
               }
            }
         }
   }
}

