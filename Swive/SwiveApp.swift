//
//  SwiveApp.swift
//  Swive
//
//  Created by Jonas Mårtensson on 2021-06-09.
//

import SwiftUI

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
    @EnvironmentObject var root: Entry 

    @State private var spawnSprites: Bool = true;
    @State private var isLoading: Bool = false;
    
    var body: some Scene {
        // The 'some' keyword works similarly to type<T> with the difference
        // being that the implementation (instead of the caller) decides the
        // type (in this case `WindowGroup` which adhears to the Scene
        // protocol)
        WindowGroup {    
            if isLoading {
               
               ProgressView() 
            }
            else {

                NavigationView {
                    ListingView("/root/")    
                }
            }
        }
    }
}
