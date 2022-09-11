import SwiftUI

// '@main' denotes the entrypoint for the application
@main struct moatApp: App {
    
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

    var body: some Scene {
        // The 'some' keyword works similarly to type<T> with the difference
        // being that the implementation (instead of the caller) decides the
        // type (in this case `WindowGroup` which adhears to the Scene
        // protocol)
        WindowGroup {    
            NavigationView {
                ZStack {
                    // The Gradient background needs to be placed inside the ZStack to appear beneath
                    // the scene (which we give a transparent background)
                    BKG_GRADIENT_LINEAR
                        .edgesIgnoringSafeArea(.vertical) // Fill entire screen 
                    FeedsView() 
                    // https://stackoverflow.com/questions/57517803/how-to-remove-the-default-navigation-bar-space-in-swiftui-navigationview 
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                }
            }
            //  https://stackoverflow.com/a/64752414/9033629
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
