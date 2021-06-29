import SwiftUI

struct ItemThumbnailView: View {

   var rssurl: String;
   var item: RssItem;
   var screenWidth: CGFloat;
   
   var apiWrapper: ApiWrapper<ServerResponse>;
   @Binding var unread: Bool;
   @Binding var unread_count: Int;
   @EnvironmentObject var alertState: AlertState;
   
   var body: some View {
       VStack (alignment: .leading, spacing: 5){
          Text("\(item.title)")
           .foregroundColor(.white)
           .font(.system(size:19,weight: .bold))
           .lineLimit(2)
           
           HStack {
             item.DateText()
              .foregroundColor(.white)
              .font(.system(size:16))
              .lineLimit(1)
           }
       }
       // This is required for the elements in the stack to actually
       // "float" to the left
       .frame(
          width:  item.getVideoId() != nil ? 
              self.screenWidth*(1-BUTTON_WIDTH_PERCENTAGE_OF_ROW) - THUMBNAIL_WIDTH - 23 :
              // Fill entire the entire row excluding 20px of padding on each side and the
              // width of the button
              self.screenWidth*(1-BUTTON_WIDTH_PERCENTAGE_OF_ROW) - X_AXIS_MARGIN_FOR_ROWS*2, 
          alignment: .leading
       )  
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
   }
}
