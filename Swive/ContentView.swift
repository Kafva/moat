//
//  ContentView.swift
//  Swive
//
//  Created by Jonas Mårtensson on 2021-06-09.
//

import SwiftUI
import SpriteKit

let COLUMN_COUNT = 6;
let ROW_COUNT = 1;
let SPRITE_SHEET = "pika-h.png"//"sheet-penguin.png";
let SPRITE_SIZE = CGSize(width:37*2, height:47*2);

struct Entry: Identifiable {
    let name: String
    let id = UUID();
}

func getTexts(count: Int) -> [Entry] {
    var arr: [Entry] = [];

    for i in 0...count {
        arr.append( Entry(name:"Item \(i)") );
    }

    return arr;
}

class SpriteScene: SKScene {
    
    let sheet = SpriteSheet(
        sheetImage: SPRITE_SHEET, 
        rows: ROW_COUNT, 
        columns: COLUMN_COUNT, 
        spacingX: 0,
        spacingY: 0, 
        spriteSize: SPRITE_SIZE
    );
    
    func getNodeCount() -> Int{
        var nodeCount=0;
        self.enumerateChildNodes(withName: "node*") {
            (node: SKNode, _) -> Void in 
                nodeCount+=1;
        }
        return nodeCount;
    }


    // The `didMove` method is triggered when we enter the scene
    override func didMove(to view: SKView) {
        // Create a physicsbody that can contain entities using
        // the frame property of the superclass
        physicsBody = SKPhysicsBody( edgeLoopFrom: frame )
    }

    // The code to run when a touch event reaches the scene
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Ensure that the touch event is not nil
        guard let touch = touches.first else { return; }
        let location = touch.location(in: self);
        
        do {
            
            let sprite = try self.sheet.getSprite(
                columnIndex: Int.random(in: 0...COLUMN_COUNT-1), 
                rowIndex: Int.random(in: 0...ROW_COUNT-1)
            );
            
            // The position of the sprite in the parennt container
            sprite.position = location;
            self.addChild(sprite);
        }
        catch { NSLog("\(error)"); }
        
        NSLog("Touched (\(location.x),\(location.y))");
        NSLog("Node count: \(self.getNodeCount())");
    }
}

struct ContentView: View {
    
    // @StateObject is needed to annotate that a property is required for
    // rendering a view (and shouldn't be deleted when the view is disposed
    // and re-drawn)

    var sceneSize: CGSize = CGSize(width: 400, height: 600);

    // Give the view a computed scene attribute
    // which creates a SpriteScene instance of a given size
    var scene: SKScene {
        let scene = SpriteScene();
        scene.size = self.sceneSize; 
        scene.scaleMode = .fill;
        return scene;
    }
    
    // The `body` property of a SwiftUI view describes its content, layout, 
    // and behavior 
    var body: some View {
            
        VStack {
            Text("Swive").font(.title);
            Text("???").font(.subheadline);
            
            Spacer();
            
            // We can add our scene as any other node in a SwiftUI `SpriteView`
            // Note that we set the same width/height as for the scene
            SpriteView( scene: self.scene ).frame( 
                width: self.sceneSize.width, 
                height: self.sceneSize.height
            )
            
            //HStack {
            //    
            //    List(getTexts(count: 3)) {
            //        Text($0.name).foregroundColor(.blue);
            //    }
            //    Image("joffrey").scaledToFit(); //.frame(width: floor(159/2), height: floor(222/2)).border(.blue);
            //
            //}
        }

    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
