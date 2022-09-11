import SwiftUI

struct ItemButtonView: View {

   var video_id: Int;
   var screenWidth: CGFloat;
   var apiWrapper: ApiWrapper<ServerResponse>;
   @State var unread: Bool;
   @EnvironmentObject var alertState: AlertState;

   init(unread_binding: Bool, video_id: Int, screenWidth: CGFloat, apiWrapper: ApiWrapper<ServerResponse>){
      self.apiWrapper = apiWrapper
      self.video_id = video_id
      self.screenWidth = screenWidth
      self.unread = unread_binding
   }
   
   var body: some View {
        // The button on the right side will toggle the 'read' status of an entry
        Button(action: {
           self.apiWrapper.setUnreadStatus(
              unread_binding: $unread, 
              video_id: video_id, 
              alert: alertState, 
              isLoading: nil
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