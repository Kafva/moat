import Foundation

extension String {
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

/* [Darkngs] [so/q/29365145] [cc by-sa 3.0] */
