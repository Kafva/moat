import SwiftUI

let PATH_REGEX     = "^/(([ A-Za-z0-9.]+)/)+$"; 
let ROOT_DIR_REGEX = "^/([ A-Za-z0-9.]+)/";

// By implementing a primitve type we automatically
// make the enum Codable
enum EntryType: String, Codable {
   case Directory = "d"
   case File = "f"
}

class Entry: ObservableObject, Codable, Equatable {
   // The codable property enables a struct to be
   // serialised/deserialised
   // https://www.hackingwithswift.com/swift4
   // https://www.hackingwithswift.com/books/ios-swiftui/sending-and-receiving-codable-data-with-urlsession-and-swiftui
   let name: String
   let type: EntryType
   var subentries: [Entry]?
   let id = UUID(); // not included in coded obejct
   
   /// Returns true if the provided entries have the same
   /// hierarchy, ignores differences in the `id` property
   public static func == (lhs: Entry, rhs: Entry) -> Bool {
      if lhs.name == rhs.name &&
         lhs.type == rhs.type &&
         lhs.subentries?.count == rhs.subentries?.count {

            let lhsSorted = lhs.subentries?.sorted(by: { $0.name > $1.name } )
            let rhsSorted = rhs.subentries?.sorted(by: { $0.name > $1.name } )

            for i in 0..<(lhsSorted?.count ?? 0) {
               if lhsSorted![i] != rhsSorted![i] {
                  return false
               }
            }
            
            return true
      }
      return false
   } 

   
   private enum CodingKeys: String, CodingKey {
      // An enum which impllements the CodingKey protocol can be used to
      // map different JSON keys to different attributes in a codable object 
      // i.e. a key-name could be mapped to an internal attribute named something else
      case name
      case type
      case subentries
      case id 
   } 
   
   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(self.name, forKey: .name)
      try container.encode(self.type, forKey: .type)
      try container.encode(self.subentries, forKey: .subentries)
   } 
   
   required init(from decoder: Decoder ) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)

      self.name = try values.decode(String.self, forKey: .name)
      self.type = try values.decode(EntryType.self, forKey: .type)
      
      if values.contains(.subentries) && self.type == .Directory {
         self.subentries = try values.decode([Entry].self, forKey: .subentries)
      }
   }

   init(name: String, type: EntryType, subentries: [Entry] = []){
      self.name = name;
      self.type = type;
      self.subentries = subentries;
   }
}

