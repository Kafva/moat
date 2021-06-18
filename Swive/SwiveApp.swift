//
//  SwiveApp.swift
//  Swive
//
//  Created by Jonas Mårtensson on 2021-06-09.
//

import SwiftUI


//public class GlobalState: ObservableObject {
//    
//    var isLoading: Bool = false
//    var alertTitle: String = ""
//    var alertMessage: String = ""
//    var showAlert: Bool = false
//}


//func makeAlert(env: Binding<GlobalState>, title: String, err: Error?) {
//  env.alertTitle = title; 
//  env.alertMessage = "\(err?.localizedDescription ?? "Unknown error")";
//  env.showAlert = true;
//  NSLog("\(title): \(env.alertMessage)");
//}
//
///// Fetch a list of all entries from the provided path
///// on the remote server
//func loadFeeds() -> Void {
//  
//  guard let url = URL(string: "http://10.0.1.30:5000/feeds") else { return } 
//  var req = URLRequest(url: url);
//  req.addValue("test", forHTTPHeaderField: "x-creds")
//
//  URLSession.shared.dataTask(with: req) { data, response, err in
//     // Create a background task to fetch data from the server
//     if data != nil {
//        do { 
//           
//           let decoded = try JSONDecoder().decode([RssFeed].self, from: data!) 
//           // If the response data was successfully decoded dispatch an update in the
//           // main thread (all UI updates should be done in the main thread)
//           // to update the state in the view
//           DispatchQueue.main.async {
//              sleep(4)
//              self.feeds = decoded;
//              env.isLoading = false;
//           }
//        }
//        catch { 
//           makeAlert(title: "Decoding error", err: err); 
//           env.isLoading = false;
//        }
//     }
//     else { 
//        makeAlert(title: "Connection error", err: err) 
//        env.isLoading = false;
//     }
//  }.resume(); // Execute the task immediatelly
//}

// '@main' denotes the entrypoint for the application
@main struct SwiveApp: App {
    
    // @State should (just like in other UI frameworks) be kept as high
    // up as possible and passed downwards. Subviews which need to know the
    // status of a @State variable are passed them as @Bindings
    // When a @State property changes -> affected views are automatically redrawn 
    // When a state variable is written using '$' it will enable a two-way
    // connection where write operations will update the state. 
    
    // @ObjectBinding is used when we need to share complex types
    // (Reference types like classes) between views
    
    // @EnviromentObject is a third property wrapper which enables a property
    // to be accessible from *any SUBview*, this is useful when we have chains
    // of views were we don't want to pass a state a value around just to use
    // it one place 
    //@EnvironmentObject var root: Entry 
    //@EnvironmentObject var serverUrl:  = "http://localhost:8080";

    // TODO List of RssFeeds, each containing a list of RssItems
    // (fetched seperatly but saved -- only fetch from '/items' when
    // the list is empty or has a diverging number of unread articles compared
    // to the 'unread' atttrbute on the RssFeed)
    //@EnvironmentObject 

    @State private var spawnSprites: Bool = true;
    //@State private var isLoading: Bool = false;
    //@StateObject var env: GlobalState = GlobalState()
    //@StateObject var feeds: RssFeeds = RssFeeds();
    
    var body: some Scene {
        // The 'some' keyword works similarly to type<T> with the difference
        // being that the implementation (instead of the caller) decides the
        // type (in this case `WindowGroup` which adhears to the Scene
        // protocol)
        WindowGroup {    
            
                NavigationView {
                   FeedsView() 
                        // https://stackoverflow.com/questions/57517803/how-to-remove-the-default-navigation-bar-space-in-swiftui-navigationview 
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                }
                //  https://stackoverflow.com/a/64752414/9033629
                .navigationViewStyle(StackNavigationViewStyle())
                // Pass the global state variable down to the feeds view
                // as an @EnviromentObject
                //.environmentObject(env)
                //.environmentObject(feeds)
        }
    }
}
