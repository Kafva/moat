import SwiftUI

class AlertState: ObservableObject {
   // The published attribute denotes that views watching this
   // observable object should re-render themselves on changes to the
   // given attribute
   @Published var show: Bool = false;
   var title: String = "";
   var message: String = "";
   
   /// Unhides an alert and sets the loading state to false
   func makeAlert(title: String, err: Error?, isLoading: Binding<Bool> ) {
      self.title = title; 
      self.message = "\(err?.localizedDescription ?? "No description available")";
      
      DispatchQueue.main.async {
         // UI changes need to be performed on the main thread
         self.show = true;
         isLoading.wrappedValue = false; 
         NSLog("===== ALERT [\(self.show)] ======\n\(title): \(self.message)");
      }
      
   }
}
