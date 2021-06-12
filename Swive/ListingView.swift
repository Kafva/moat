import SwiftUI

/**** API ****/
// 1. Fetch list of entries
// 2. Get file content
// 3. Write file content (maybe)



struct ListingView: View {

   let dirPath: String;
   
   // TODO implement check agianst top level 'root' state
   @State var entries = [Entry]();
   
   init?(_ dirPath: String) {
      // https://stackoverflow.com/questions/57128547/swiftui-list-color-background
      UITableView.appearance().backgroundColor = .clear
      UITableViewCell.appearance().backgroundColor = .clear
      
      if  dirPath.range(of: PATH_REGEX, options: .regularExpression) != nil {
         self.dirPath = dirPath;
      }
      else {
         NSLog("Path validation failed: \(dirPath)");
         self.dirPath = "/invalid/"; // TODO
      }
   }
   
   /// Fetch a list of all entries from the provided path
   /// on the remote server
   func loadEntries() -> Void {
      guard let url = URL(string: "http://10.0.1.30:8080/dir.json") else { return } 
      let req = URLRequest(url: url);

      URLSession.shared.dataTask(with: req) { data, response, err in
         // Create a background task to fetch data from the server
         if data != nil {
            do { 
               
               let decoded = try JSONDecoder().decode(Entry.self, from: data!) 
               // If the response data was successfully decoded dispatch an update in the
               // main thread (all UI updates should be done in the main thread)
               // to update the state in the view
               DispatchQueue.main.async {
                  self.entries = decoded.subentries ?? [];
               }
            }
            catch { NSLog("Decoding failure \(error)"); }
         }
         else {
            NSLog("Error fetching data: \(err?.localizedDescription ?? "Unknown error")");
         }
      }.resume(); // Execute the task immediatelly
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
               
               ForEach(entries, id: \.id ) { entry in
                  // We need the entry class to have an ID
                  // to iterate over it using ForEach()
               
                  NavigationLink(destination: ListingView( "\(self.dirPath)\(entry.name)/" ) ) {
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
            .onAppear(perform: loadEntries)

            
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