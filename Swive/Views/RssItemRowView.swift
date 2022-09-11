import SwiftUI

struct RssItemRowView: View {

   var rssurl: String
   var item: RssItem;
   var screenWidth: CGFloat;
   var apiWrapper = ApiWrapper<ServerResponse>()
   let location = CGPoint(x: INITIAL_X_POS, y: 0);
   
   @Binding var unread_count: Int;
   @EnvironmentObject var alertState: AlertState;

   var body: some View {
      HStack {
        // If the item is YouTube video extract the thumbnail
        // the mq (medium quality) version lacks black borders
        //     320x180
        if let video_id = item.getVideoId() {
           UrlImageView("https://img.youtube.com/vi/\(video_id)/mqdefault.jpg")
               .frame(
                  width: THUMBNAIL_WIDTH,  
                  height: THUMBNAIL_HEIGHT,
                  alignment: .center
           )
           .padding(.leading, 5)
           .onTapGesture {
              // Make the thumbnail clickable to visit the link
              UIApplication.shared.open(URL(string: item.url)!)
           }   

        } 
        else {
           Spacer().frame(width: X_AXIS_MARGIN_FOR_ROWS)
        }

        // Both of these subviews require access to the `unread_count` since
        // they may update the `unread` value in which case the `unread_count`
        // also needs to be modified 
        ItemThumbnailView(item: self.item, screenWidth: self.screenWidth)
        
        ItemButtonView(
           unread_count: self.$unread_count,
           unread: self.item.unread, 
           video_id: self.item.id,
           rssurl: self.rssurl,
           screenWidth: self.screenWidth, 
           apiWrapper: apiWrapper
        )
        .environmentObject(alertState)

      }
      .frame(width: self.screenWidth, alignment: .leading)
      .padding(.bottom, 0)
      // Prevent spacing between the back-button in the navbar and the first item
      .position(location)
   }
}
