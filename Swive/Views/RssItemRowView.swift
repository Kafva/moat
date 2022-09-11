import SwiftUI

struct RssItemRowView: View {

   var item: RssItem;
   var screenWidth: CGFloat;

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
              NSLog("Clicked thumbnail")
           }
        } 
        else {
           Spacer().frame(width: 15)
        }

        VStack (alignment: .leading, spacing: 5){
           Link("\(item.title)", destination: URL(string: item.url)! )
             .foregroundColor(.white)
             .font(.system(size:19,weight: .bold))
             .lineLimit(2)
            

            HStack {
           
              Button(action: {
                 NSLog("Toggling")
              }) {
                 Image(
                    systemName:  item.unread ? "sparkles" : "plus"
                 ).resizable().frame(
                    width: BUTTON_WIDTH, height: BUTTON_HEIGHT, alignment: .center
                 )
              }
              
              item.DateText()
                .foregroundColor(.white)
                .font(.system(size:16))
                .lineLimit(1)
                .padding(.leading, 5)

            }
        }
        // This is required for the elements in the stack to actually
        // "float" to the left
        .frame(
           width:  item.getVideoId() != nil ? 
               self.screenWidth - THUMBNAIL_WIDTH - 23 :
               self.screenWidth - 15, 
           alignment: .leading
        )  
      }
      .frame(width: self.screenWidth, alignment: .leading)
      .padding(.bottom, 7)
   }
}
