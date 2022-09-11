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

class ImageLoader: ObservableObject {
    
    @Published var imageData = Data()
    
    init(imageURL: String) {
        
        let cache = URLCache.shared
        let req = URLRequest(
            url: URL(string: imageURL)!, 
            cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, 
            timeoutInterval: 5.0
        )
        
        // Use the cache if the data has already been fetched 
        if let data = cache.cachedResponse(for: req)?.data {
            self.imageData = data
        } 
        else {
            URLSession.shared.dataTask(with: req) { data, res, err in
                
                if let data = data , let res = res {
                    // Nil guard for both the response and data

                    // Save the response in the cache
                    let cachedData = CachedURLResponse(response: res, data: data)
                    cache.storeCachedResponse(cachedData, for: req)
                    
                    DispatchQueue.main.async {
                        self.imageData = data
                    }
                }
            }.resume()
        }
    }
}
