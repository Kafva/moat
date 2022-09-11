import Foundation

extension String {
    /// https://stackoverflow.com/a/35360697/9033629
    func fromBase64() -> String? {
       guard let data = Data(base64Encoded: self) else {
           return nil
       }

       return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
       return Data(self.utf8).base64EncodedString()
    }
}
