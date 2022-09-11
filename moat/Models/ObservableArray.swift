import SwiftUI

/// Wrapper to enable arrays with the @StateObject attribute
class ObservableArray<T>: ObservableObject {
   var arr:[T];
   init(_ arr: [T] = []){
      self.arr = arr;
   }
}

