import SwiftUI

extension Color {
    /// https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-hex-color-to-a-uicolor
    init(hex: String) {
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff00_0000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff_0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000_ff00) >> 8) / 255

                    self.init(red: Double(r), green: Double(g), blue: Double(b))
                    return
                }
            }
        }

        NSLog(
            "Failed to convert '\(hex)' into a Color object -- using fallback value"
        )
        self.init(red: 0, green: 0, blue: 0)
    }
}
