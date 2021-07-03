import SwiftUI

/// Wrapper to enable arrays with the @StateObject attribute,
/// probably not a great idea in some ways...
class ObservableArray<T>: ObservableObject {
   var arr: [T];
   init(_ arr: [T] = []){
      self.arr = arr;
   }
}
