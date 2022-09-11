import SpriteKit

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
    
    private func setupTimers(){
       
       Timer.scheduledTimer(
           timeInterval: 1, 
           target: self, 
           selector: #selector(addRandomSprite), 
           userInfo: nil,
           repeats: true
        ); 
       
       Timer.scheduledTimer(
           timeInterval: 0.5, 
           target: self, 
           selector: #selector(cycleSprites), 
           userInfo: nil,
           repeats: true
        ); 
    }

    /// The position is the position of the sprite in the parent container
    /// If no position is provided a random position will be chosen
    /// No sprite will be added if the limit has been reached
    func addSprite(position: CGPoint) {
        
        guard nodeCount < MAX_SPRITE_COUNT else { 
            #if DEBUG
                NSLog("Limit reached (\(nodeCount)/\(MAX_SPRITE_COUNT)) -- not adding a new sprite");
            #endif
            return; 
        }

        do {
            let sprite = try self.sheet.getSprite(
                columnIndex: Int.random(in: 0...COLUMN_COUNT-1), 
                rowIndex: Int.random(in: 0...ROW_COUNT-1),
                name: "\(BASE_NODE_NAME)\(self.nodeCount)"
            );
            self.nodeCount+=1

            sprite.position = position;
            NSLog("\(sprite.position) manual"); 
            
            self.sprites.append(sprite);
            self.addChild(sprite);
            
            // Pick a point to move to which will have each sprite move
            // towards the upper right corner along the same line 
            let targetPos = CGPoint(
                x: self.size.width + position.x,
                y: self.size.height + position.y
            )

            let actions = SKAction.sequence([
                SKAction.fadeIn(withDuration: 1),
                SKAction.move(to: targetPos, duration: 5),
                SKAction.fadeAlpha(to: 0, duration: 1),
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
    
    @objc func addRandomSprite() {
        guard nodeCount < MAX_SPRITE_COUNT else { 
            #if DEBUG
                NSLog("Limit reached (\(nodeCount)/\(MAX_SPRITE_COUNT)) -- not adding a new sprite");
            #endif
            return; 
        }
        
        let spawnX = CGFloat.random( in: 0...(self.size.width  / 2) );

        // Default spawn locations
        let position = CGPoint(
            x: arc4random() % 2 == 0 ? 
                spawnX : -1 * spawnX,
            y: -1 * CGFloat.random( in: 0...(self.size.height / 4) )
        )

        do {
            let sprite = try self.sheet.getSprite(
                columnIndex: Int.random(in: 0...COLUMN_COUNT-1), 
                rowIndex: Int.random(in: 0...ROW_COUNT-1),
                name: "\(BASE_NODE_NAME)\(self.nodeCount)"
            );
            self.nodeCount+=1

            sprite.position = position;
            
            self.sprites.append(sprite);
            NSLog("\(sprite.position) rand()");
            self.addChild(sprite);
            
            // Pick a point to move to which will have each sprite move
            // towards the upper right corner along the same line 
            
            var posX = self.size.width  + position.x;
            var posY = self.size.height + position.y;
            let k = abs(position.y/position.x);

            // Ensure that every sprite reaches the end of the screen
            while posX < self.size.width || posY < self.size.height {
                posY+=k;
                posX+=k;
            }

            let targetPos = CGPoint(
                //x: self.size.width  + position.x,
                //y: self.size.height + position.y
                x: posX,
                y: posY
            )

            NSLog("\(sprite.position) fix()");

            let actions = SKAction.sequence([
                SKAction.fadeIn(withDuration: 1),
                SKAction.move(to: targetPos, duration: 5),
                SKAction.fadeAlpha(to: 0, duration: 1),
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
    
    private func getNodeCount() -> Int{
        var nodeCount=0;
        self.enumerateChildNodes(withName: "\(BASE_NODE_NAME)*") {
            (node: SKNode, _) -> Void in 
                nodeCount+=1;
        }
        return nodeCount;
    }

    // The `didMove` method is triggered when we enter the scene
    override func didMove(to view: SKView) {
        // Setup the global timer for sprite updates
        self.setupTimers();
    }

    // The code to run when a touch event reaches the scene
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Ensure that the touch event is not nil
        guard let touch = touches.first else { return; }
        let location = touch.location(in: self);
        
        self.addSprite(position: location);
        
        #if DEBUG 
            NSLog("Touched (\(round(location.x)),\(round(location.y)))");
            NSLog("Node count: \(self.getNodeCount())");
        #endif
    }
}
