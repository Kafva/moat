import SwiftUI

extension TextField {
   func customStyle(width: CGFloat) -> some View {
      return self.disableAutocorrection(true)
         .padding(10)
         .background(Color.black.opacity(0.2))
         .cornerRadius(5)
         .frame(
            width: width, 
            height: ROW_HEIGHT, 
            alignment: .center
        )
   }
}

extension SecureField {
   func customStyle(width: CGFloat) -> some View {
      return self.disableAutocorrection(true)
         .padding(10)
         .background(Color.black.opacity(0.2))
         .cornerRadius(5)
         .frame(
            width: width, 
            height: ROW_HEIGHT, 
            alignment: .center
        )
   }
}
