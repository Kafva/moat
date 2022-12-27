import SwiftUI
import SpriteKit

struct LoadingView: View {

    var sceneSize: CGSize;

    // Give the view a computed scene attribute
    // which creates a SpriteScene instance of a given size
    var scene: SpriteScene {
        let scene = SpriteScene();
        scene.size = self.sceneSize;
        scene.scaleMode = .fill;
        return scene;
    }

    var body: some View {
            // We can add our scene as any other node in a SwiftUI `SpriteView`
            // Note that we set the same width/height as for the scene
            SpriteView( scene: self.scene, options: [.allowsTransparency] ).frame(
                width: self.sceneSize.width,
                height: self.sceneSize.height
            )
    }
}
