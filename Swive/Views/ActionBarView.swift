import SwiftUI

struct ActionBarView: View {
   
   @Binding var searchString: String;
   var searchBarWidth: CGFloat;

   var body: some View {
      HStack(alignment: .top) {
         SearchView( barWidth: searchBarWidth, searchBinding: $searchString )
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
   }
}

