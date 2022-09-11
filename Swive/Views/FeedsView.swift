import SwiftUI

struct FeedsView: View {

   @StateObject var feeds: ObservableArray<RssFeed> = ObservableArray();
   @StateObject var alertState: AlertState = AlertState();
   
   @State var isLoading: Bool = true;
   @State var searchString: String = "";
   
   // To prevent a bug which hides the navbar's back-button we need to prevent the user from clicking
   // a `NavigationLink` while they are editing a text field. To do this we use this state variable
   // which disables all views containing nav-links while the search bar is being interacted with  
   // Solutions to hide the keyboard:
   //    https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield
   // were found to prevent the back-button from being hidden but the button would not be functional
   // We do not need to worry about the textfields in the `SettingsView` since we don't need a back-button
   // to be displayed when we leave it for the `FeedsView`
   @State var textFieldFocused: Bool = false
   
   var apiWrapper = ApiWrapper<RssFeed>()

   /// Computed property to determine if the current query yields no results
   var noMatches: Bool { 
      !feeds.arr.contains(where: { feed in  
         feed.title.range(of: searchString, options: .caseInsensitive) != nil 
      }) && 
      searchString != ""
   }
   
   init() {
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
                        textFieldFocused: $textFieldFocused,
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
                     
                        if feed.title.range(of: searchString, options: .caseInsensitive) != nil || searchString == "" {
                           RssFeedRowView(feed: feed, screenWidth: geometry.size.width) 
                              .disabled(textFieldFocused)
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

