import SwiftUI

struct SearchView: View {

   var barWidth: CGFloat;
   @Binding var searchBinding: String;

   var body: some View {
      HStack (alignment: .center, spacing: 5){
         Image(systemName: "magnifyingglass")
         TextField("Search...", text: $searchBinding)
            .padding(10)
            .background(Color.black.opacity(0.2))
            .cornerRadius(5)
            .frame(
               width: self.barWidth, 
               height: ROW_HEIGHT, 
               alignment: .center
           )
      }
   }
}

