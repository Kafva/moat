import SwiftUI

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

