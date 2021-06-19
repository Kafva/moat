import SpriteKit
import SwiftUI;

class SpriteScene: SKScene {
    

    var sprites: [SKSpriteNode] = [];
    var nodeCount: uint = 0;

    let sheet = SpriteSheet(
        sheetImage: SPRITE_SHEET, 
        rows: ROW_COUNT, 
        columns: COLUMN_COUNT, 
        spacingX: 0,
        spacingY: 0, 
        spriteSize: SPRITE_SIZE
    );
    
    var spawnTimer: Timer?;
    var spriteFrameTimer: Timer?;

    private func setupTimers(){
       
       self.spawnTimer = Timer.scheduledTimer(
           timeInterval: SPRITE_SPAWN_INTERVAL, 
           target: self, 
           selector: #selector(addSpriteAtRandomPos), 
           userInfo: nil,
           repeats: true
        ); 
       
       self.spriteFrameTimer = Timer.scheduledTimer(
           timeInterval: SPRITE_NEW_FRAME_INTERVAL, 
           target: self, 
           selector: #selector(cycleSprites), 
           userInfo: nil,
           repeats: true
       ); 
    }
    
    /// Go through all SKSpriteNode objects in the scene and update their
    /// sprite image.
    /// The @objc label is needed for functions that are ran using a timer
    @objc func cycleSprites() {
            
            self.enumerateChildNodes(withName: "\(BASE_NODE_NAME)*") {
                (node: SKNode, _) -> Void in 
                do {
                    (node as! SKSpriteNode).texture = try self.sheet.getTexture(
                        columnIndex: Int.random(in: 0...COLUMN_COUNT-1), 
                        rowIndex: Int.random(in: 0...ROW_COUNT-1)
                    )
                }
                catch { NSLog("\(error)"); }
            }
    }

    @objc func addSpriteAtRandomPos() {

        let spawnX = CGFloat.random( in: 0...(self.size.width  / 1) );

        // Default spawn location calculation
        let spawnPosition = CGPoint(
            x: arc4random() % 2 == 0 ? 
                spawnX : -1 * spawnX,
            y: -1 * CGFloat.random( in: 0...(self.size.height / 4) )
        )
        
        // Pick a point to move to which will have each sprite move
        // towards the upper right corner along the same line 
        var posX = self.size.width  + spawnPosition.x;
        var posY = self.size.height + spawnPosition.y;
        let k = abs(spawnPosition.y/spawnPosition.x);

        // Ensure that every sprite reaches the end of the screen
        while posX < self.size.width || posY < self.size.height {
            posY+=k;
            posX+=k;
        }

        let targetPos = CGPoint(
            x: posX,
            y: posY
        )

        self.addSprite(spawnPosition, targetPos);
    }

    /// Add a sprite from the provided sprite sheet to the scene at the given position
    /// the sprite will travel towards the point specfied in the second argument
    func addSprite(_ spawnPosition: CGPoint, _ targetPos: CGPoint) {
        
        guard nodeCount < MAX_SPRITE_COUNT else { 
            //#if DEBUG
            //    NSLog("Limit reached (\(nodeCount)/\(MAX_SPRITE_COUNT)) -- not adding a new sprite");
            //#endif
            return; 
        }

        do {
            let sprite = try self.sheet.getSprite(
                columnIndex: Int.random(in: 0...COLUMN_COUNT-1), 
                rowIndex: Int.random(in: 0...ROW_COUNT-1),
                name: "\(BASE_NODE_NAME)\(self.nodeCount)"
            );
            self.nodeCount+=1

            sprite.position = spawnPosition;
            //NSLog("Placing new sprite at (\(round(sprite.position.x)),\(round(sprite.position.y)))"); 
            
            self.sprites.append(sprite);
            self.addChild(sprite);
            
            let actions = SKAction.sequence([
                //SKAction.fadeIn(withDuration: 1),
                SKAction.move(to: targetPos, duration: 5),
                //SKAction.fadeAlpha(to: 0, duration: 1),
            ])

            sprite.run(actions, completion: {
                sprite.removeFromParent()
                if self.nodeCount > 0 { 
                    self.nodeCount-=1;
                }
            });
        }
        catch { NSLog("\(error)"); }
    }

    private func getNodeCount() -> Int{
        var nodeCount=0;
        self.enumerateChildNodes(withName: "\(BASE_NODE_NAME)*") {
            (node: SKNode, _) -> Void in 
                nodeCount+=1;
        }
        return nodeCount;
    }

    /// The `didMove` method is triggered when we enter the scene
    override func didMove(to view: SKView) {
        // Use a clear background to show the gradient behind the scene in the ZStack
        self.backgroundColor = .clear;

        // Setup the global timer for sprite updates
        self.setupTimers();
        
        // Immediatelly add a few sprites
        for _ in 0...INITIAL_SPAWN_COUNT {
            self.addSpriteAtRandomPos();
        } 
    }

    /// The code to run when a touch event reaches the scene
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Ensure that the touch event is not nil
        guard let touch = touches.first else { return; }
        let location = touch.location(in: self);
        
        // Pick a point to move to which will have the new sprite move
        // towards the upper right corner of the screenn 
        let targetPos = CGPoint(
            x: self.size.width + location.x,
            y: self.size.height + location.y
        )
        
        self.addSprite(location, targetPos);
        
        //#if DEBUG 
        //    NSLog("Touched (\(round(location.x)),\(round(location.y)))");
        //    NSLog("Node count: \(self.getNodeCount())");
        //#endif
    }
}
