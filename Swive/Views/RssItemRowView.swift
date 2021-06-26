import SwiftUI

struct RssItemRowView: View {

   var item: RssItem;
   var screenWidth: CGFloat;
   @State var opacity: Double = 1;
   
   @State private var location: CGPoint = CGPoint(x: INITIAL_X_POS, y: 0)
   var toggleReadGesture: some Gesture {
      DragGesture()
         .onChanged { value in
            print("@x:\(self.location.x) moved to \(value.location.x)")

            if value.location.x >= INITIAL_X_POS {
               //DispatchQueue.main.async {
                  self.opacity =   Double(
                     abs(COMMIT_X_POS - value.location.x)  / 
                     COMMIT_X_POS
                  ) 
                  print("YEP")
               //}

               // Only accept horizontal dragging motions
               self.location.x = value.location.x
            }
         }
         .onEnded({ _ in
         
               if self.location.x >= COMMIT_X_POS {
                  print("Commit change!")
               }

               // Reset to original position on ended drag gesture
               print("Resetting to x:\(INITIAL_X_POS)")
               self.location.x = INITIAL_X_POS
               self.opacity = 1;
               
         })
   } 

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
            if item.unread {
               Image(
                  systemName: "sparkles" 
               )
               .resizable()
               .foregroundColor(Color.blue)
               .frame(
                  width: BUTTON_WIDTH, height: BUTTON_HEIGHT, alignment: .center
               )
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
      .opacity( self.opacity )
      .frame(width: self.screenWidth, alignment: .leading)
      .padding(.bottom, 7)
      .position(location)
      
      // We register the gestures for the entire row and not
      // for individual sub elmenets
      
      // Using drag gestures inside a scrollview is fairly buggy,
      // without the empty tap gesture it becomes a lot more
      // common for drag gestures to be registered when we mean to
      // scroll vertically (they still do to some extent)
      // https://developer.apple.com/forums/thread/123034
      //.onTapGesture {}   // This disables the link...
      .gesture(toggleReadGesture)
      .onTapGesture {
         UIApplication.shared.open(URL(string: item.url)!)
      }

   }
}
