import SwiftUI

let SERVER_REQUEST_TIMEOUT = 3.0


/***** UI dimensions *****/
let IMAGE_WIDTH = CGFloat(50);
let ROW_HEIGHT = CGFloat(50);

let THUMBNAIL_WIDTH = CGFloat(320/2);
let THUMBNAIL_HEIGHT = CGFloat(180/2);
let BUTTON_WIDTH = CGFloat(25);
let BUTTON_HEIGHT = CGFloat(25);


let INITIAL_X_POS = THUMBNAIL_WIDTH + 35

/***** Colors *******/
let BKG_GRADIENT_LINEAR = LinearGradient(
    gradient: Gradient(colors: [
        Color(hex: "#606c88"),
        Color(hex: "#3f4c6b")
    ]), 
    startPoint: .top, 
    endPoint: .bottom
);

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

