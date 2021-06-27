import SwiftUI

struct ItemThumbnailView: View {

   var item: RssItem;
   var screenWidth: CGFloat;
   
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
              self.screenWidth*(1-BUTTON_WIDTH_PERCENTAGE_OF_ROW) - 15, 
          alignment: .leading
       )  
       .onTapGesture {
          // Make the entire left side clickable to visit the link
          UIApplication.shared.open(URL(string: item.url)!)
       }   
   }
}
