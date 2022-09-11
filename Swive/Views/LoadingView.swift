import SwiftUI
import SpriteKit

struct LoadingView: View {
    
    // @StateObject is needed to annotate that a property is required for
    // rendering a view (and shouldn't be deleted when the view is disposed
    // and re-drawn)
    @Binding var active: Bool;
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
            // We can add our scene as any other node in a SwiftUI `SpriteView`
            // Note that we set the same width/height as for the scene
            SpriteView( scene: self.scene, options: [.allowsTransparency] ).frame( 
                width: self.sceneSize.width, 
                height: self.sceneSize.height
            )
            //THIS
            .onChange(of: self.active, perform: { active in
                print("onChange =>")

                // Remove all sprites
                for sprite in self.scene.sprites {
                    sprite.removeFromParent()
                }

                // Deactivate all timers
                self.scene.spawnTimer?.invalidate()
                self.scene.spriteFrameTimer?.invalidate()
                
                self.scene.spawnTimer = nil
                self.scene.spriteFrameTimer = nil
            })
        ///.onDisappear(perform: {
        ///    // Clean up when the SpriteView is left
        ///    // TODO doesn't work
        ///    print("onDisappear =>")

        ///    // Remove all sprites
        ///    for sprite in self.scene.sprites {
        ///        sprite.removeFromParent()
        ///    }

        ///    // Deactivate all timers
        ///    self.scene.spawnTimer?.invalidate()
        ///    self.scene.spriteFrameTimer?.invalidate()
        ///})
    }
}
