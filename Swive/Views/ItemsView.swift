import SwiftUI

struct ItemsView: View {

   var feedurl: String

   @StateObject var items: ObservableArray<RssItem> = ObservableArray();
   @StateObject var alertState: AlertState = AlertState();
   @State var isLoading: Bool = true;

   var apiWrapper = ApiWrapper<RssItem>()

   init?(_ feedurl: String) {
      self.feedurl = feedurl;
   }
   
   var body: some View {
      GeometryReader { geometry in 
         ZStack {
            // We need to re-add the background since the
            // ItemsView is *not* rendered on top of the view that
            // is presented from SwiveApp.swift
            BKG_GRADIENT_LINEAR
               .edgesIgnoringSafeArea(.vertical) // Fill entire screen 
            
            // Gain access to the screen dimensions to perform proper sizing
            if self.isLoading {
               LoadingView(
                  width: geometry.size.width, 
                  height: geometry.size.height,  
                  loadingText:"Loading..."
               )
               .onAppear(perform: {
                  self.apiWrapper.loadRows(
                     rows: items, 
                     alert: alertState, 
                     isLoading: $isLoading,
                     rssurl: self.feedurl                  
                  )} 
               )
            }
            else {
               ScrollView(.vertical) { 
                  // The alignment parameter for a VStack concerns horizontal alignment
                  VStack(alignment: .center, spacing: 0) {

                     ForEach(self.items.arr, id: \.id ) { item in
                        RssItemRowView(item: item, screenWidth: geometry.size.width)
                     }
                     .listRowBackground(Color.clear)
                     .frame(width: .infinity, alignment: .center)
                  }
               }
            }
         } 
         .alert(isPresented: $alertState.show) {
            Alert(
               title: Text(alertState.title), 
               message: Text(alertState.message), 
               dismissButton: .default(Text("OK"))
         )}
      }
   }
}

