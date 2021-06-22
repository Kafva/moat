import SwiftUI

struct FeedsView: View {

   @StateObject var feeds: ObservableArray<RssFeed> = ObservableArray();
   @StateObject var alertState: AlertState = AlertState();
   
   @State var isLoading: Bool = true;
   @State var searchString: String = "";

   var apiWrapper = ApiWrapper<RssFeed>()

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

                     ForEach(feeds.arr, id: \.id ) { feed in
                        // We need the entry class to have an ID
                        // to iterate over it using ForEach()
                     
                        if feed.title.contains(searchString) || searchString == "" {
                           RssFeedRowView(feed: feed, screenWidth: geometry.size.width) 
                           .environmentObject(alertState)
                        }
                     }
                  }
                  .listRowBackground(Color.clear)
               }
               // We pass the alertState object downwards, updates to it will
               // always use this alert() definition
               .alert(isPresented: $alertState.show ) {
                  var a: Alert;
                  if alertState.alertWithTwoButtons {
                     a = Alert(
                        title: Text(alertState.title),
                        primaryButton: .destructive(
                           Text("No"),
                           action: {}
                        ),
                        secondaryButton: .default(
                           Text("Yes"), 
                           action: {} 
                        )
                     )
                  }
                  else {
                     a = Alert(
                        title: Text(alertState.title), 
                        message: Text(alertState.message), 
                        dismissButton: .default(Text("OK"))
                     )
                  }
                  return a
               }
            }
         }
   }
}

