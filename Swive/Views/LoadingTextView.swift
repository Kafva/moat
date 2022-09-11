import SwiftUI

struct LoadingTextView: View {

  var loadingText: String = "Loading..."

  var body: some View {

    Text(loadingText)
      .font(.largeTitle).bold()
      .animation(Animation.easeOut(duration: 1).repeatForever(autoreverses: true) )
      //.frame(width: .infinity, alignment: .center)
  }
}


