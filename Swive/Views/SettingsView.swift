import SwiftUI

struct SettingsView: View {

   var feeds: [RssFeed]
   @State var finishedCount: Int = 0; 
   @State var isLoading: Bool = false;
   
   @State var spritesOn: Bool = true;
   @State var serverLocation: String = "10.0.1.30:5000"
   @State var serverKey: String = "test"
   
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
               VStack(alignment: .leading, spacing: 10) {
                  Toggle("Spawn sprites on loading screen", isOn: $spritesOn) 
                     .onChange(of: spritesOn) { value in
                        print("THIS",value) 
                     }
                  HStack {
                     Text("Server location")
                        .lineLimit(1)
                        .frame(width: geometry.size.width*0.3, alignment: .leading)
                     
                     TextField("IP or domain name", text: $serverLocation, onCommit: {
                        print("CHANNGE IP")
                     })
                     .customStyle(width: geometry.size.width * 0.5)
                  }
                  HStack {
                     Text("Server key")
                        .frame(width: geometry.size.width*0.3, alignment: .leading)
                     SecureField("", text: $serverKey, onCommit: {
                        print("Wow")
                     })
                     .customStyle(width: geometry.size.width * 0.5)
                  }

                  Button(action: {
                    self.isLoading = true
                    setLogosInUserDefaults(feeds: feeds, finishedCount: $finishedCount, completion: { logos in
                        // Apply the changes to the logos array
                        // Note that we use `UserDefaults.standard` and not just `UserDefaults`
                        UserDefaults.standard.setValue(logos, forKey: "logos")
                        self.isLoading = false
                    })
                  }) {
                     Label("Reload YouTube feed logos", systemImage: "arrow.clockwise")
                  }
                  .padding(10)
               }
               .frame(width: geometry.size.width * 0.8, alignment: .leading)
            }
        }
      }
   }
}


