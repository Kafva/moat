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
    @State private var visible = true

    var sceneSize: CGSize = CGSize(
        width: UIScreen.main.bounds.width, 
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
    
    private func pulsateText() {
        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
            visible.toggle()
        }
    } 

    // The `body` property of a SwiftUI view describes its content, layout, 
    // and behavior 
    var body: some View {

        ZStack {
            // The Gradient background needs to be placed inside the ZStack to appear beneath
            // the scene (which we give a transparent background)
            LinearGradient(gradient: BKG_GRADIENT, startPoint: .top, endPoint: .bottom)

            // We can add our scene as any other node in a SwiftUI `SpriteView`
            // Note that we set the same width/height as for the scene
            SpriteView( scene: self.scene, options: [.allowsTransparency] ).frame( 
                width: self.sceneSize.width, 
                height: self.sceneSize.height
            ); 
            
            Text("Loading...")
                .font(.largeTitle).bold().opacity(visible ? 1 : 0.5)
                .onAppear(perform: pulsateText)
        }
         

    }
}