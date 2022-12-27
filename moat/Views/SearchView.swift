import SwiftUI

struct SearchView: View {

   var barWidth: CGFloat;
   @Binding var searchBinding: String;
   @Binding var textFieldFocused: Bool;

   var body: some View {
      HStack(alignment: .center, spacing: 5){
         Image(systemName: "magnifyingglass")
         TextField("Search...", text: $searchBinding, onEditingChanged: { started in
            if started {
               textFieldFocused = true
            }
            else {
               textFieldFocused = false
            }
         })
         .customStyle(width: self.barWidth)
         .autocapitalization(.none)
      }
   }
}
