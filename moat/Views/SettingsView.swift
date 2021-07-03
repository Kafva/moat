import SwiftUI

struct SettingsView: View {

   var feeds: [RssFeed]
   @State var finishedCount: Int = 0; 
   @State var isLoading: Bool = false;
   @State var infiniteLoad: Bool = false;
   
   @State var logosOn: Bool = UserDefaults.standard.bool(forKey: "logosOn") ;
   @State var spritesOn: Bool = UserDefaults.standard.bool(forKey: "spritesOn") ;
   @State var serverLocation: String = UserDefaults.standard.string(forKey: "serverLocation") ?? ""
   @State var serverKey: String = "" 
   
   init(feeds: [RssFeed]){
      self.feeds = feeds;
      setViewTransparency();
   }
   
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
                  if UserDefaults.standard.bool(forKey: "spritesOn") {
                     LoadingView(
                        sceneSize: CGSize(
                           width: geometry.size.width, 
                           height: geometry.size.height  
                        )
                     )
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                  }
                 
                 // To prevent the loadingView from being redrawn whenever
                 // the loading text changes we keep them seperate from each other
                 LoadingTextView(loadingText: self.infiniteLoad ? 
                    "Loading..." : 
                    String(format: "Fetching icons\n%.0f %%", 
                       (Double(self.finishedCount)/Double(self.feeds.count)) * 100
                    )
                 )
               }
            }
            else {
               VStack(alignment: .leading, spacing: 10) {
                   
                  Toggle("Show YouTube logo for feeds", isOn: $logosOn) 
                     .onChange(of: logosOn) { _ in
                        UserDefaults.standard.setValue(logosOn, forKey: "logosOn")
                     }
                  Toggle("Spawn sprites on loading screen", isOn: $spritesOn) 
                     .onChange(of: spritesOn) { _ in
                        UserDefaults.standard.setValue(spritesOn, forKey: "spritesOn")
                     }
                  
                     HStack {
                        Text("Server location")
                           .lineLimit(1)
                           .frame(width: geometry.size.width*0.3, alignment: .leading)
                        
                        TextField("IP or domain name", text: $serverLocation, onEditingChanged: { started in 
                           if !started {
                              // `onEditingChanged` is triggered upon entering and leaving a textfield
                              // using `onCommit` misses changes that are made without hiting <ENTER> 
                              UserDefaults.standard.setValue(serverLocation, forKey: "serverLocation")
                           }
                        })
                        .customStyle(width: geometry.size.width * 0.5)
                        .autocapitalization(.none)
                     }
                     HStack {
                        Text("Server key")
                           .frame(width: geometry.size.width*0.3, alignment: .leading)
                        SecureField("(Hidden)", text: $serverKey)
                        .customStyle(width: geometry.size.width * 0.5)
                        // `onEditingChanged` doesn't exist for SecureFields, to have all changes
                        // automatically commited we therefore need to use `onChange`
                        .onChange(of: serverKey, perform: { value in
                           // Set the creds value in KeyChainStorage
                           setCreds(value)
                        })
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

                     Button(action: {
                       self.infiniteLoad = true
                       self.isLoading = true
                     }) {
                        Label("Infinite loading screen", systemImage: "timelapse")
                     }
                     .padding(10)
               }
               .frame(width: geometry.size.width * 0.8, alignment: .leading)
               .onAppear(perform: {
                  // For some reason the state isn't recorded properly in the UI if we
                  // navigate back to the feed and then back to the settings so we
                  // use this hack to set the values correctly
                  // Note that the server key field isn't included since
                  // we don't want to supply the current key in plain text to the user
                  spritesOn = UserDefaults.standard.bool(forKey: "spritesOn") 
                  serverLocation = UserDefaults.standard.string(forKey: "serverLocation") ?? ""
               })

            }
        }
      }
   }
}
