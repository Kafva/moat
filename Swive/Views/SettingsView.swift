import SwiftUI

// One would have prefered to use CocoaPods but for the LSP to reconginze the
// dependceny we need to use the built in Xcode option to add a package
//  File > Swift Packages > Add Package Dependency...
import KeychainAccess

struct SettingsView: View {

   //init?() {
   //   // https://stackoverflow.com/questions/57128547/swiftui-list-color-background
   //   UITableView.appearance().backgroundColor = .clear
   //   UITableViewCell.appearance().backgroundColor = .clear
   //   
   //   // https://stackoverflow.com/a/58974331/9033629 
   //   UINavigationBar.appearance().barTintColor = .clear
   //   UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
   //}
   
   func getCreds(){
   }

   var body: some View {
      
      GeometryReader { geometry in 
         // Gain access to the screen dimensions to perform proper sizing
      
         ZStack {
            // The Gradient background needs to be placed inside the ZStack to appear beneath
            // the scene (which we give a transparent background)
            
            BKG_GRADIENT_LINEAR
               .edgesIgnoringSafeArea(.vertical) // Fill entire screen 

            // Configure secret key
            // Configure server address  
        }

      }
   }
}


