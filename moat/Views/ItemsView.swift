import SwiftUI

struct ItemsView: View {

   var feedurl: String
   var apiWrapper = ApiWrapper<RssItem>()

   @StateObject var items: ObservableArray<RssItem> = ObservableArray();
   @StateObject var alertState: AlertState = AlertState();
   @State var isLoading: Bool = true;
   
   @Binding var unread_count: Int

   init?(feedurl: String, unread_count: Binding<Int>) {
      setViewTransparency()
      self.feedurl = feedurl;
      self._unread_count = unread_count;
   }
   
   var body: some View {
      GeometryReader { geometry in 
         ZStack {
            // We need to re-add the background since the
            // ItemsView is *not* rendered on top of the view that
            // is presented from moatApp.swift
            BKG_GRADIENT_LINEAR
               .edgesIgnoringSafeArea(.vertical) // Fill entire screen 
            
            // Gain access to the screen dimensions to perform proper sizing
            if self.isLoading {
               ZStack {
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
                            rows: items, 
                            alert: alertState, 
                            isLoading: $isLoading,
                            rssurl: self.feedurl                  
                         ) 
                      })
               }
            }
            else {

               ScrollView(.vertical) { 
                  // The alignment parameter for a VStack concerns horizontal alignment
                  VStack(alignment: .center, spacing: Y_AXIS_SPACING_FOR_ITEMS) {

                     ForEach(self.items.arr, id: \.id ) { item in
                        RssItemRowView(
                           rssurl: feedurl, 
                           item: item, 
                           screenWidth: geometry.size.width,
                           unread_count: $unread_count
                        )
                        .environmentObject(alertState)
                     }
                     .listRowBackground(Color.clear)
                     .frame(width: geometry.size.width, alignment: .center)
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
