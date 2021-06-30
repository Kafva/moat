import SwiftUI

/// https://www.lukecsmith.co.uk/2020/11/20/loading-from-url-and-caching-images-in-swiftui/
struct UrlImageView: View {
    
    @ObservedObject var imageLoader: ImageLoader

    init(_ url: String) {
        imageLoader = ImageLoader(imageURL: url)
    }

    var body: some View {
          Image(uiImage: UIImage(data: self.imageLoader.imageData) ?? UIImage())
              .resizable() // Must be applied before modifying the frame size
              .clipped()
    }
}
