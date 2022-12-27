import SwiftUI

struct FeedLogoView: View {

    var channelId: String
    var logoUrl: String = ""

    init(channelId: String){
        self.channelId = channelId

        if self.channelId != "" {
           self.logoUrl = getLogoUrlFromUserDefaults(channelId: channelId) ?? ""
        }
    }

    var body: some View {
        if logoUrl != "" {
            UrlImageView(logoUrl)
            .clipShape(Circle())
               .frame(
                  width: IMAGE_WIDTH,
                  height: ROW_HEIGHT,
                  alignment: .center
            )
            .padding(.leading, 5)
        }
        else {
            Image(DEFAULT_LOGO_IMAGE_NAME)
              .resizable() // Must be applied before modifying the frame size
              .clipped()
            .clipShape(Circle())
               .frame(
                  width: IMAGE_WIDTH,
                  height: ROW_HEIGHT,
                  alignment: .center
            )
            .padding(.leading, 5)
        }
    }
}
