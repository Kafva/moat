import SwiftUI

struct SettingsView: View {

   var feeds: [RssFeed]
   @State var finishedCount: Int = 0; 
   @State var isLoading: Bool = false;
   
   var body: some View {

      GeometryReader { geometry in 
         // Gain access to the screen dimensions to perform proper sizing
      
         ZStack {
            // The Gradient background needs to be placed inside the ZStack to appear beneath
            // the scene (which we give a transparent background)
            
            BKG_GRADIENT_LINEAR
               .edgesIgnoringSafeArea(.vertical) // Fill entire screen 
            
            if self.isLoading {
               ZStack {
                  LoadingView(
                     sceneSize: CGSize(
                        width: geometry.size.width, 
                        height: geometry.size.height  
                     )
                  )
                 .navigationBarTitle("")
                 .navigationBarHidden(true)
                 
                 // To prevent the loadingView from being redrawn whenever
                 // the loading text changes we keep them seperate from each other
                 LoadingTextView( loadingText: 
                    String(format: "Fetching icons\n%.0f %%", 
                       (Double(self.finishedCount)/Double(self.feeds.count)) * 100
                    )
                 )
               }
            }
            else {
               VStack {
                  Button(action: {
                    self.isLoading = true
                    setLogosInUserDefaults(feeds: feeds, finishedCount: $finishedCount, completion: { logos in
                        // Apply the changes to the logos array
                        // Note that we use `UserDefaults.standard` and not just `UserDefaults`
                        UserDefaults.standard.setValue(logos, forKey: "logos")
                        self.isLoading = false
                    })
                  }) {
                     Image(systemName: "arrow.clockwise").resizable().frame(
                        width: 25, height: 25, alignment: .center
                     )
                  }
                  .padding(10)
               }
            }
        }
      }
   }
}


