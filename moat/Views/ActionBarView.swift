import SwiftUI

struct ActionBarView: View {
   
   @EnvironmentObject var feeds: ObservableArray<RssFeed>
   @EnvironmentObject var alertState: AlertState
   @Binding var searchString: String
   @Binding var isLoading: Bool
   
   @Binding var textFieldFocused: Bool;

   var searchBarWidth: CGFloat
   
   var apiWrapper = ApiWrapper<RssFeed>()

   var body: some View {
      HStack(alignment: .top) {
         SearchView( barWidth: searchBarWidth, searchBinding: $searchString, textFieldFocused: $textFieldFocused)
            .padding(.bottom, 20)
         
        // Settings and reload buttons
        NavigationLink(destination: SettingsView(feeds: feeds.arr) ){
            Image(systemName: "slider.horizontal.3").resizable().frame(
               width: 25, height: 25, alignment: .center
            )
         }
         .padding(10)
         .disabled(textFieldFocused)


         // Bruh... https://developer.apple.com/forums/thread/677333
         // this only seems to be a partial fix
         NavigationLink(destination: EmptyView()) {
            EmptyView()
         }

         Button(action: {
            isLoading = true
            self.apiWrapper.reloadFeeds(
               rows: feeds,
               alert: alertState,
               isLoading: $isLoading
            ) 
         }) { 
               Image(systemName: "arrow.clockwise").resizable().frame(
               width: 25, height: 25, alignment: .center
            )
         }
         .padding(10)
         .disabled(textFieldFocused)
      }
   }
}
