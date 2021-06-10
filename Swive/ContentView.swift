//
//  ContentView.swift
//  Swive
//
//  Created by Jonas Mårtensson on 2021-06-09.
//

import SwiftUI
import SpriteKit

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

struct ContentView: View {
    
    // @StateObject is needed to annotate that a property is required for
    // rendering a view (and shouldn't be deleted when the view is disposed
    // and re-drawn)

    //var sceneSize: CGSize = CGSize(width: 400, height: 600);
    var sceneSize: CGSize = CGSize(
        width: UIScreen.main.bounds.height, 
        height: UIScreen.main.bounds.height
    );

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
            
        ZStack {
            //Text("???").font(.subheadline);
            
            // We can add our scene as any other node in a SwiftUI `SpriteView`
            // Note that we set the same width/height as for the scene
            SpriteView( scene: self.scene ).frame( 
                width: self.sceneSize.width, 
                height: self.sceneSize.height
            )
            
            Text("Loading...").font(.title);
            
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
