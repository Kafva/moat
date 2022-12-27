import SwiftUI

struct RssFeedRowView: View {

   var feed: RssFeed;
   var screenWidth: CGFloat;
   @StateObject var alertState: AlertState = AlertState()
   var showLogos = UserDefaults.standard.bool(forKey: "logosOn")

   // This state is passed onwards to the  ItemsView for each feed so
   // that the unread_count is upated in the feeds view when changes are made
   @State var unread_count: Int

   var apiWrapper = ApiWrapper<ServerResponse>()

   init(feed: RssFeed, screenWidth: CGFloat){
      self.feed = feed
      self.screenWidth = screenWidth
      self.unread_count = feed.unread_count
   }

   var body: some View {
      HStack {

         if self.showLogos {
            NavigationLink(destination: ItemsView(feedurl: feed.rssurl, muted: feed.muted, unread_count: $unread_count)
            ) {
               FeedLogoView(channelId: feed.getChannelId() ?? "")
            }
         }

         VStack(alignment: .leading, spacing: 5){
            NavigationLink(destination: ItemsView(feedurl: feed.rssurl, muted: feed.muted, unread_count: $unread_count)
            ){
                Text("\(feed.title)")
                  .foregroundColor(.white)
                  .font(.system(size: 22,weight: .bold))
                  .lineLimit(1)
            }
            Link("\(URL(string: feed.url)?.host ?? "???")", destination: URL(string: feed.url)! )
               .foregroundColor(.blue)
               .font(.system(size: 18))
               .lineLimit(1)
         }
         // This is required for the elements in the stack to actually
         // "float" to the left
         .frame(
            width: self.showLogos ? self.screenWidth * 0.5 : self.screenWidth * 0.6,
            alignment: .leading
         )
         .padding( self.showLogos ? 0 : 15)

         if !self.feed.muted {
            Text(  "\(self.unread_count)/\(feed.item_count)" )
               .padding(7)
               .background(Color.black.opacity(0.2))
               .cornerRadius(5)
               .foregroundColor(.white)
               .font(Font.system(size: 18, weight: .bold))
               .frame(
                  // The image leads with 5px of padding
                  width: (self.showLogos ? self.screenWidth * 0.5 : self.screenWidth * 0.4)  - (IMAGE_WIDTH+5),
                  alignment: Alignment.center
               )
               .lineLimit(1)
               .onTapGesture {
                 self.alertState.title = "Mark all entries for \(self.feed.title) as read?"
                 self.alertState.message = ""
                 self.alertState.type = AlertType.Choice
                 self.alertState.show = true
               }
         }
         else {
            Image(systemName: "speaker.slash")
               .padding(7)
               .background(Color.black.opacity(0.2))
               .cornerRadius(5)
               .foregroundColor(.white)
               .font(Font.system(size: 18, weight: .bold))
               .frame(
                  width: (self.showLogos ? self.screenWidth * 0.5 : self.screenWidth * 0.4)  - (IMAGE_WIDTH+5),
                  alignment: Alignment.center
               )
               .lineLimit(1)
         }
      }
      .padding(.bottom, 5)
      // We need to handle both a choice and error alert for each row
      // in case the '/unread' endpoint returns an error
      .alert(isPresented: $alertState.show ) {
            var a: Alert
            if alertState.type == AlertType.Choice {
               a = Alert(
                  title: Text(alertState.title),
                  primaryButton: .destructive(
                     Text("No"),
                     action: { /* Do nothing */ }
                  ),
                  secondaryButton: .default(
                     Text("Yes"),
                     action: {
                        self.apiWrapper.setAllItemsAsRead(
                           unread_count: self.$unread_count,
                           rssurl: self.feed.rssurl,
                           alert: self.alertState
                        )
                     }
                  )
               )
            }
            else {
               a = Alert(
                  title: Text(alertState.title),
                  message: Text(alertState.message),
                  dismissButton: .default(Text("OK"))
               )
            }
            return a
      }

   }
}
