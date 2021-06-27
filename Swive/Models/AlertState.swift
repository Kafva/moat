import SwiftUI

class AlertState: ObservableObject {
   // The published attribute denotes that views watching this
   // observable object should re-render themselves on changes to the
   // given attribute
   @Published var show: Bool = false;
   var title: String = "";
   var message: String = "";

   /// When producing alerts for the 'mark all as read' feature this attribute
   /// will corresponnd to the rssurl of the feed in question
   var feedUrl: String = "";
   
   /// Unhides an alert and sets the loading state to false
   func makeAlert(title: String, err: Error?, isLoading: Binding<Bool>?, feedUrl: String = "") {
      
      self.title = title; 
      self.message = "\(err?.localizedDescription ?? "No description available")";
      self.feedUrl = feedUrl
      
      DispatchQueue.main.async {
         // UI changes need to be performed on the main thread
         self.show = true;
         isLoading?.wrappedValue = false; 
         // NSLog("===== ALERT [\(self.show)] ======\n\(title): \(self.message)");
      }
      
   }
}
