import SwiftUI

struct FeedsView: View {

   @StateObject var feeds: ObservableArray<RssFeed> = ObservableArray();
   @StateObject var alertState: AlertState = AlertState();
   
   @State var isLoading: Bool = true;
   @State var searchString: String = "";

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
                        sceneSize: CGSize(
                           width: geometry.size.width, 
                           height: geometry.size.height
                        )
                     )
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
                     // When the rows are not loaded we need to add additional padding for the items in the bar 
                     .padding(.leading,  feeds.arr.count == 0 ? 15 : 0 )
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
                  }
                  .listRowBackground(Color.clear)
               }
            }
         }
   }
}

