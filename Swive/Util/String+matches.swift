import Foundation

extension String {

  func matches(_ regex: String) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        return results.map {
            String(self[Range($0.range, in: self)!])
        }
    }
    catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
  }

}
