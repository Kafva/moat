import SwiftUI

struct RssItemRowView: View {

   var item: RssItem;
   var screenWidth: CGFloat;

   var body: some View {
      // | 50px | 0.5 %      | 0.5 % - 50px |
      HStack {
        //AsyncImage(url: URL(string: "https://i.imgur.com/yywewrD.png"))
        Image("umbreon")
              .resizable() // Must be applied before modifying the frame size
              .clipShape(Circle())
              .frame(
                 width: IMAGE_WIDTH,  
                 height: ROW_HEIGHT, 
                 alignment: .center
           )
           .padding(.leading, 5)

        VStack (alignment: .leading, spacing: 5){
           Link("\(item.title)", destination: URL(string: item.url)! )
             .foregroundColor(.white)
             .font(.system(size:23,weight: .bold))
             .lineLimit(1)
           item.DateText()
             .foregroundColor(.white)
             .font(.system(size:16))
             .lineLimit(1)
        }
        // This is required for the elements in the stack to actually
        // "float" to the left
        .frame(
           width: self.screenWidth  - IMAGE_WIDTH, 
           alignment: .leading
        )
      }
      .frame(width: self.screenWidth, alignment: .leading)
      .padding(.bottom, 5)
   }
}
