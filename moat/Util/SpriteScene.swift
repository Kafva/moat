import SpriteKit
import SwiftUI

class SpriteScene: SKScene {
    var sprites: [SKSpriteNode] = []
    var nodeCount: uint = 0

    let sheet = SpriteSheet(
        sheetImage: SPRITE_SHEET,
        rows: ROW_COUNT,
        columns: COLUMN_COUNT,
        spacingX: 0,
        spacingY: 0,
        spriteSize: SPRITE_SIZE
    )

    /// Go through all SKSpriteNode objects in the scene and update their sprite image.
    /// The @objc label is needed for functions that are ran using NSTimer (which we don't rely on)
    func cycleSprites() {
        self.enumerateChildNodes(withName: "\(BASE_NODE_NAME)*") {
            (node: SKNode, _) -> Void in
            do {
                (node as! SKSpriteNode).texture = try self.sheet.getTexture(
                    columnIndex: Int.random(in: 0...COLUMN_COUNT - 1),
                    rowIndex: Int.random(in: 0...ROW_COUNT - 1)
                )
            } catch { print("\(error)") }
        }
    }

    func addSpriteAtRandomPos() {
        let spawnX = CGFloat.random(in: 0...(self.size.width / 1))

        // Default spawn location calculation
        let spawnPosition = CGPoint(
            x: arc4random() % 2 == 0 ? spawnX : -1 * spawnX,
            y: -1 * CGFloat.random(in: 0...(self.size.height / 4))
        )

        // Pick a point to move to which will have each sprite move
        // towards the upper right corner along the same line
        var posX = self.size.width + spawnPosition.x
        var posY = self.size.height + spawnPosition.y
        let k = abs(spawnPosition.y / spawnPosition.x)

        // Ensure that every sprite reaches the end of the screen
        while posX < self.size.width || posY < self.size.height {
            posY += k
            posX += k
        }

        let targetPos = CGPoint(
            x: posX,
            y: posY
        )

        self.addSprite(spawnPosition, targetPos)
    }

    /// Add a sprite from the provided sprite sheet to the scene at the given position
    /// the sprite will travel towards the point specfied in the second argument
    func addSprite(_ spawnPosition: CGPoint, _ targetPos: CGPoint) {

        guard nodeCount < MAX_SPRITE_COUNT else {
            #if DEBUG
                print(
                    "Limit reached (\(nodeCount)/\(MAX_SPRITE_COUNT)) -- not adding a new sprite"
                )
            #endif
            return
        }

        do {
            let sprite = try self.sheet.getSprite(
                columnIndex: Int.random(in: 0...COLUMN_COUNT - 1),
                rowIndex: Int.random(in: 0...ROW_COUNT - 1),
                name: "\(BASE_NODE_NAME)\(self.nodeCount)"
            )
            self.nodeCount += 1

            sprite.position = spawnPosition

            #if DEBUG
                print(
                    "Placing new sprite at (\(round(sprite.position.x)),\(round(sprite.position.y)))"
                )
            #endif

            self.sprites.append(sprite)
            self.addChild(sprite)

            let actions = SKAction.sequence([
                SKAction.move(to: targetPos, duration: 5)
            ])

            sprite.run(
                actions,
                completion: {
                    sprite.removeFromParent()
                    if self.nodeCount > 0 {
                        self.nodeCount -= 1
                    }
                })
        } catch { print("\(error)") }
    }

    private func getNodeCount() -> Int {
        var nodeCount = 0
        self.enumerateChildNodes(withName: "\(BASE_NODE_NAME)*") {
            (_: SKNode, _) -> Void in
            nodeCount += 1
        }
        return nodeCount
    }

    /// The `didMove` method is triggered when we enter the scene
    override func didMove(to view: SKView) {
        // Use a clear background to show the gradient behind the scene in the ZStack
        self.backgroundColor = .clear

        // Immediatelly add a few sprites
        for _ in 0...INITIAL_SPAWN_COUNT {
            self.addSpriteAtRandomPos()
        }

        // Setup the repeated actions to switch frames for all sprites and
        // to spawn new sprites
        run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run({ self.cycleSprites() }),
                    SKAction.wait(forDuration: SPRITE_NEW_FRAME_INTERVAL),
                ])
            ))

        run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run({ self.addSpriteAtRandomPos() }),
                    SKAction.wait(forDuration: SPRITE_SPAWN_INTERVAL),
                ])
            ))
    }

    /// The code to run when a touch event reaches the scene
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        // Ensure that the touch event is not nil
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Pick a point to move to which will have the new sprite move
        // towards the upper right corner of the screenn
        let targetPos = CGPoint(
            x: self.size.width + location.x,
            y: self.size.height + location.y
        )

        self.addSprite(location, targetPos)
    }
}
