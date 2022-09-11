import SwiftUI

struct LoadingTextView: View {

  var loadingText: String = "Loading..."
  @State private var bouncing = false
  
  var body: some View {

    Text(loadingText)
      .font(.largeTitle).bold()
      .frame(maxHeight: 100, alignment: bouncing ? .bottom : .top)
      .animation(Animation.easeOut(duration: 2).repeatForever(autoreverses: true) )
      .onAppear {
        self.bouncing.toggle()
      }
  }
}
