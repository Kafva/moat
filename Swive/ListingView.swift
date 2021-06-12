import SwiftUI

/**** API ****/
// 1. Fetch list of entries
// 2. Get file content
// 3. Write file content (maybe)

let PATH_REGEX     = "^/(([ A-Za-z0-9.]+)/)+$"; 
let ROOT_DIR_REGEX = "^/([ A-Za-z0-9.]+)/";

enum EntryType {
   case Directory
   case File
}

class Entry: ObservableObject {
   // The codable property enables a struct to be
   // serialised/deserialised
   // https://www.hackingwithswift.com/swift4
   // https://www.hackingwithswift.com/books/ios-swiftui/sending-and-receiving-codable-data-with-urlsession-and-swiftui
   let name: String
   let type: EntryType
   var subentries: [Entry]?
   let id = UUID();
   
   
   init(name: String, type: EntryType){
      self.name = name;
      self.type = type;
      self.subentries = nil;
   }
}

/// Fetch a list of all entries from the provided path
/// on the remote server
func getEntries(path: String) -> [Entry] {
    var arr: [Entry] = [];

    for i in 0...4 {
        arr.append( Entry(name:"Item \(i)", type: .File) );
    }

   return arr;
   
   
   //if ( path.range(of: PATH_REGEX, options: .regularExpression) != nil ){

   //}
   //else {
   //   NSLog("Path validation failed: \(path)");
   //}
}

struct ListingView: View {

   let dirPath: String;
   
   @State var entries = [Entry]();
   
   init(_ dirPath: String) {
      // https://stackoverflow.com/questions/57128547/swiftui-list-color-background
      UITableView.appearance().backgroundColor = .clear
      UITableViewCell.appearance().backgroundColor = .clear
      
      self.dirPath = dirPath;
   }

   var body: some View {
      
         ZStack {
            // The Gradient background needs to be placed inside the ZStack to appear beneath
            // the scene (which we give a transparent background)
            
            BKG_GRADIENT_LINEAR
               .edgesIgnoringSafeArea(.vertical) // Fill entire screen 
               
            VStack(alignment: .leading, spacing: 20) {
               
               if self.dirPath == "/root/" {
                  NavigationLink(destination: LoadingView("Loading...") ) {
                    Text("Go to loading view")
                  }
               }

               // Without a VStack the list entries will adhear
               // to the enclosing ZStack
               // We need the entry class to have an ID
               // to iterate over it using ForEach()
               ForEach( getEntries(path: self.dirPath), id: \.id ) { entry in
               
                  NavigationLink(destination: ListingView( self.dirPath + entry.name ) ) {
                        HStack(alignment: .firstTextBaseline) {
                           Image("umbreon")
                              .resizable() // Must be applied before modifying the frame size
                              .clipShape(Circle())
                              .frame(width: 50, height: 50, alignment: .leading)

                           Text("\(entry.name)")
                              .foregroundColor(.white)
                              .font(.system(size:30))
                              .fontWeight(.bold)
                        }
                        .padding(10)
                     }
                  }
            }
            .listRowBackground(Color.clear)
            
            
            
            
            
            
            
            //NavigationView {
            //VStack {
            //      //Button("Toggle full screen") {
            //      self.fullScreen.toggle()
            //      .navigationBarTitle("Swive")
            //      .navigationBarHidden(self.fullScreen)
            //      
            //      Spacer()
            //      
            //      NavigationLink(destination: LoadingView("Loading...") ) {
            //         Text("Go to loading bar")
            //            .foregroundColor(.white)
            //            .font(.system(size:30))
            //            .fontWeight(.bold)
            //         }
            //      }//.navigationBarTitle("Swive")
            //}//.statusBar(hidden: self.fullScreen)
      }
   }
}