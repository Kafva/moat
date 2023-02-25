import SwiftUI

struct RssItemRowView: View {

    var rssurl: String
    var muted: Bool
    var item: RssItem
    var screenWidth: CGFloat
    var apiWrapper = ApiWrapper<ServerResponse>()
    let location = CGPoint(x: INITIAL_X_POS, y: 0)

    @State var unread: Bool
    @Binding var unread_count: Int
    @EnvironmentObject var alertState: AlertState

    init(
        rssurl: String, muted: Bool, item: RssItem, screenWidth: CGFloat,
        unread_count: Binding<Int>
    ) {
        self.rssurl = rssurl
        self.muted = muted
        self.item = item
        self.screenWidth = screenWidth
        self.unread = self.item.unread
        self._unread_count = unread_count
    }

    var body: some View {
        HStack {
            // If the item is YouTube video extract the thumbnail
            // the mq (medium quality) version lacks black borders
            //     320x180
            if let video_id = item.getVideoId() {
                UrlImageView(
                    "https://img.youtube.com/vi/\(video_id)/mqdefault.jpg"
                )
                .frame(
                    width: THUMBNAIL_WIDTH,
                    height: THUMBNAIL_HEIGHT,
                    alignment: .center
                )
                .padding(.leading, 5)
                .onTapGesture {
                    // Automatically toggle the 'unread' status to 'read' when clicking an item
                    if unread {
                        self.apiWrapper.setUnreadStatus(
                            unread_count: $unread_count,
                            unread_binding: $unread,
                            rssurl: self.rssurl,
                            video_id: self.item.id,
                            alert: alertState
                        )
                    }
                    UIApplication.shared.open(URL(string: item.url)!)
                }

            } else {
                Spacer().frame(width: X_AXIS_MARGIN_FOR_ROWS)
            }

            // Both of these subviews require access to the `unread_count` since
            // they may update the `unread` value in which case the `unread_count`
            // also needs to be modified
            ItemThumbnailView(
                rssurl: self.rssurl,
                item: self.item,
                screenWidth: self.screenWidth,
                apiWrapper: apiWrapper,
                unread: self.$unread,
                unread_count: self.$unread_count
            )

            if !muted {
                ItemButtonView(
                    unread_count: self.$unread_count,
                    unread: self.$unread,
                    video_id: self.item.id,
                    rssurl: self.rssurl,
                    screenWidth: self.screenWidth,
                    apiWrapper: apiWrapper
                )
                .environmentObject(alertState)
            }
        }
        .frame(width: self.screenWidth, alignment: .leading)
        .padding(.bottom, 0)
        // Prevent spacing between the back-button in the navbar and the first item
        .position(location)
    }
}
