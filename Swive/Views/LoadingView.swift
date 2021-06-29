import SwiftUI
import SpriteKit

struct LoadingView: View {
    
    // @StateObject is needed to annotate that a property is required for
    // rendering a view (and shouldn't be deleted when the view is disposed
    // and re-drawn)
    @Binding var active: Bool;
    var sceneSize: CGSize;
    
    // To enable deactivation of the timers used in the scene we need to define them at the view layer
    @State var spawnTimer: Timer?;
    @State var spriteFrameTimer: Timer?;
    
    // Give the view a computed scene attribute
    // which creates a SpriteScene instance of a given size
    var scene: SpriteScene {
        let scene = SpriteScene();
        scene.size = self.sceneSize; 
        scene.scaleMode = .fill; 
        return scene;
    }

    /// Sets up scheduled timers for events (frame updates and spawning of new sprites)
    /// in the SKScene object of the view
    private func setupTimers(){
       
       self.spawnTimer = Timer.scheduledTimer(
           timeInterval: SPRITE_SPAWN_INTERVAL, 
           target: self.scene, 
           selector: #selector(SpriteScene.addSpriteAtRandomPos), 
           userInfo: nil,
           repeats: true
        ); 
       
       self.spriteFrameTimer = Timer.scheduledTimer(
           timeInterval: SPRITE_NEW_FRAME_INTERVAL, 
           target: self.scene, 
           selector: #selector(SpriteScene.cycleSprites), 
           userInfo: nil,
           repeats: true
       ); 
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
            .onAppear(perform: {
                // Setup the timers that schedule frame updates for all sprites
                // and the spawn event for new sprites
                self.setupTimers()
            })
            .onChange(of: self.active, perform: { active in
                // Deactivate all timers when the view becomes inactive to avoid
                // uneccessary computations
                self.spawnTimer?.invalidate()
                self.spriteFrameTimer?.invalidate()
            })
    }
}
