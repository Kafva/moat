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
    var loadingText: String 

    init(_ loadingText: String) {
        self.loadingText = loadingText;
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isHidden = false
    }

    // @StateObject is needed to annotate that a property is required for
    // rendering a view (and shouldn't be deleted when the view is disposed
    // and re-drawn)
    @State private var visible: Bool = true;

    var sceneSize: CGSize = CGSize(
        width: UIScreen.main.bounds.width, 
        height: UIScreen.main.bounds.height
    );

    // Give the view a computed scene attribute
    // which creates a SpriteScene instance of a given size
    var scene: SpriteScene {
        let scene = SpriteScene();
        scene.size = self.sceneSize; 
        scene.scaleMode = .fill; 
        return scene;
    }
    
    private func pulsateText() {
        // .withAnimation is an explicit animation while
        // .animation provides implicit animations
        //  https://swiftui-lab.com/swiftui-animations-part1/
        withAnimation(Animation.easeInOut(duration: 1)
            .repeatForever(autoreverses: true)) {
            visible.toggle()
        }
    } 

    // The `body` property of a SwiftUI view describes its content, layout, 
    // and behavior 
    var body: some View {

        ZStack {
            // The Gradient background needs to be placed inside the ZStack to appear beneath
            // the scene (which we give a transparent background)
            BKG_GRADIENT_LINEAR
                .edgesIgnoringSafeArea(.vertical) // Fill entire screen 
                // To avoid the pulsating effect from applying beyond the loading text
                // we need to set the implicit animation value to nil
                .animation(nil)

            // We can add our scene as any other node in a SwiftUI `SpriteView`
            // Note that we set the same width/height as for the scene
            SpriteView( scene: self.scene, options: [.allowsTransparency] ).frame( 
                width: self.sceneSize.width, 
                height: self.sceneSize.height
            )
            .onDisappear(perform: {
                // Clean up when the SpriteView is left
                NSLog("DISSAPPEARING!!");

                // Remove all sprites
                //for sprite in self.scene.sprites {
                //    sprite.removeFromParent()
                //}

                // Deactivate all timers
                // TODO move up this STATE!
                
                self.scene.spawnTimer?.invalidate()
                self.scene.spriteFrameTimer?.invalidate()
            })
            
            
            Text(self.loadingText)
                .font(.largeTitle).bold()
                .opacity(visible ? 1 : 0.5)
                .onAppear(perform: pulsateText) 
                .navigationBarHidden(true) //TODO
        }
        //.statusBar(hidden: true)
    }
    
}
