import SwiftUI

struct RssFeedRowView: View {

   var feed: RssFeed;
   var screenWidth: CGFloat;

   var body: some View {
      // | 50px | 0.5 %      | 0.5 % - 50px |
      HStack {
         NavigationLink(destination: ItemsView(feed.rssurl) ){
            Image("umbreon")
               .resizable() // Must be applied before modifying the frame size
               .clipShape(Circle())
               .frame(
                  width: IMAGE_WIDTH,  
                  height: ROW_HEIGHT, 
                  alignment: .center
            )
            .padding(.leading, 5)
         }

         VStack (alignment: .leading, spacing: 5){
            NavigationLink(destination: ItemsView(feed.rssurl) ){
                Text("\(feed.title)")
                  .foregroundColor(.white)
                  .font(.system(size:22,weight: .bold))
                  .lineLimit(1)
            }
            Link("\(URL(string: feed.url)?.host ?? "???")", destination: URL(string: feed.url)! )
               .foregroundColor(.blue)
               .font(.system(size:18))
               .lineLimit(1)
         }
         // This is required for the elements in the stack to actually
         // "float" to the left
         .frame(
            width: self.screenWidth * 0.5, 
            alignment: .leading
         )
         
         
         Text( "\(feed.unread_count)/\(feed.item_count)" )
            .padding(7)
            .background(Color.black.opacity(0.2))
            .cornerRadius(5)
            .foregroundColor(.white)
            .font(Font.system(size:18, weight: .bold))
            .frame(
               // The image leads with 5px of padding
               width: self.screenWidth * 0.5  - (IMAGE_WIDTH+5), 
               alignment: Alignment.center
            )
            .lineLimit(1) 
      }
      .padding(.bottom, 5)

   }
}

