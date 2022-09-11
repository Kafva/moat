import SwiftUI

struct RssItemRowView: View {

   var item: RssItem;
   var screenWidth: CGFloat;
   let location = CGPoint(x: INITIAL_X_POS, y: 0);
   
   var apiWrapper = ApiWrapper<ServerResponse>()

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
        } 
        else {
           Spacer().frame(width: 90)
        }

        ItemThumbnailView(item: self.item, screenWidth: self.screenWidth)
        
        ItemButtonView(
           unread_binding: self.item.unread, 
           video_id: self.item.id, 
           screenWidth: self.screenWidth, 
           apiWrapper: apiWrapper
        )
      }
      .frame(width: self.screenWidth, alignment: .leading)
      .padding(.bottom, 0)
      // Prevent spacing between the back-button in the navbar and the first item
      .position(location)
   }
}
