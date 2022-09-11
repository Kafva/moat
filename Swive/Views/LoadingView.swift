//
//  LoadingView.swift
//  Swive
//
//  Created by Jonas Mårtensson on 2021-06-09.
//

import SwiftUI
import SpriteKit

struct LoadingView: View {
    
    // TODO make updateable
    @State var loadingText: String 
    
    init(width: CGFloat, height: CGFloat, loadingText: String) {
        self.loadingText = loadingText;
        self.sceneSize = CGSize(
            width: width,
            height: height
        )
    }

    // @StateObject is needed to annotate that a property is required for
    // rendering a view (and shouldn't be deleted when the view is disposed
    // and re-drawn)
    @State private var visible: Bool = true;

    var sceneSize: CGSize;

    // Give the view a computed scene attribute
    // which creates a SpriteScene instance of a given size
    var scene: SpriteScene {
        let scene = SpriteScene();
        scene.size = self.sceneSize; 
        scene.scaleMode = .fill; 
        return scene;
    }
    
    // The `body` property of a SwiftUI view describes its content, layout, 
    // and behavior 
    var body: some View {

        ZStack {
            // We can add our scene as any other node in a SwiftUI `SpriteView`
            // Note that we set the same width/height as for the scene
            SpriteView( scene: self.scene, options: [.allowsTransparency] ).frame( 
                width: self.sceneSize.width, 
                height: self.sceneSize.height
            )
            .onDisappear(perform: {
                // Clean up when the SpriteView is left
                NSLog("DISSAPPEARING!!");
                // TODO doesn't work

                // Remove all sprites
                //for sprite in self.scene.sprites {
                //    sprite.removeFromParent()
                //}

                // Deactivate all timers
                
                self.scene.spawnTimer?.invalidate()
                self.scene.spriteFrameTimer?.invalidate()
            })
            
            
            Text(self.loadingText)
                .font(.largeTitle).bold()
                .animation(Animation.easeOut(duration: 1).repeatForever(autoreverses: true) )
        }
    }
    
}
