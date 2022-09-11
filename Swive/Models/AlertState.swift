import SwiftUI

enum ServerConnectionError: Error, LocalizedError {
    case noServerLocation
    case invalidKey
    case noServerKey
    case unexpected(code: Int)
    
    // The error description will be shown when a `throw` occurs
    // and is required by the LocalizedError protocol
    public var errorDescription: String? {
        switch self {
        case .noServerLocation:
            return NSLocalizedString("No server location has been configured", comment: "")
        case .noServerKey:
            return NSLocalizedString("No server key has been configured", comment: "")
        case .invalidKey:
            return NSLocalizedString("Invalid server key", comment: "")
        case .unexpected(_):
            return NSLocalizedString("Unexpected error", comment: "")
        }
    }
}

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
