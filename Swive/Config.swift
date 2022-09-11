import SwiftUI

/***** Colors *******/
let BKG_GRADIENT = Gradient(colors: [
    Color(hex: "#606c88"),
    Color(hex: "#3f4c6b")
]); 

/***** Sprites *******/
let BASE_NODE_NAME = "node";

/// No new sprites will be spawned when the total number
/// reaches this value
let MAX_SPRITE_COUNT = 14;
let INITIAL_SPAWN_COUNT = 3;

/// Configure in accordance with the sprite sheet being used 
let COLUMN_COUNT = 6;
let ROW_COUNT = 1;
let SPRITE_SIZE = CGSize(width:37*2, height:47*2);
let SPRITE_SHEET = "pika-h.png";


/// The interval (in seconds) to cycle frames in a sprite object
let SPRITE_NEW_FRAME_INTERVAL = 0.5;
let SPRITE_SPAWN_INTERVAL: Double = 1;

