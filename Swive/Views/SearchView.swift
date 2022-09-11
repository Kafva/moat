import SwiftUI

struct SearchView: View {

   var barWidth: CGFloat;
   @Binding var searchBinding: String;

   var body: some View {
      HStack (alignment: .center, spacing: 5){
         Image(systemName: "magnifyingglass")
         TextField("Search...", text: $searchBinding)
            .customStyle(width: self.barWidth)
      }
   }
}

