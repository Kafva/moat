import SwiftUI

struct ItemButtonView: View {

   var rssurl: String;
   var video_id: Int;
   var screenWidth: CGFloat;
   var apiWrapper: ApiWrapper<ServerResponse>;
   @Binding var unread: Bool;
   @Binding var unread_count: Int;
   @EnvironmentObject var alertState: AlertState;

   init(unread_count: Binding<Int>, unread: Binding<Bool>, video_id: Int, rssurl: String, screenWidth: CGFloat, apiWrapper: ApiWrapper<ServerResponse>){
      self.apiWrapper = apiWrapper
      self.video_id = video_id
      self.rssurl = rssurl
      self.screenWidth = screenWidth
      self._unread_count = unread_count
      self._unread = unread
   }
   
   var body: some View {
        // The button will toggle the 'read' status of an entry
        Button(action: {
           self.apiWrapper.setUnreadStatus(
              unread_count: $unread_count,
              unread_binding: $unread, 
              rssurl: self.rssurl, 
              video_id: video_id, 
              alert: alertState
            )
         }) {
           ZStack {
              // To prevent the image from being scaled to fill the entire button
              // we use a ZStack with a background beneath the image itself
              RoundedRectangle(cornerRadius: 15, style: .continuous)
              .fill(unread ? Color.blue.opacity(0.2) : Color.clear)  
              .frame(
                 width: self.screenWidth*BUTTON_WIDTH_PERCENTAGE_OF_ROW, 
                 height: THUMBNAIL_HEIGHT, 
                 alignment: .center
              )

              Image(
                 systemName: unread ? "sparkles" : "plus" 
              )
              .foregroundColor( unread ? Color.white : Color.white.opacity(0.5) )
           }
        }
   }
}
