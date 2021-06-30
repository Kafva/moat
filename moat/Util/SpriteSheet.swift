import SpriteKit

enum CustomError: Error {
    case indexOutOfRange(String)
}

public class SpriteSheet {
    
    let sheet: SKTexture
    let rows: Int
    let columns: Int
    let spacingX: CGFloat
    let spacingY: CGFloat
    let spriteSize: CGSize

    /// The spriteSize should be the size of the sprite inside the view it is being placed
    init(sheetImage: String, rows: Int, columns: Int, spacingX: CGFloat, spacingY: CGFloat, spriteSize: CGSize){
        self.columns = columns;
        self.rows = rows;
        self.spacingX = spacingX;
        self.spacingY = spacingY;
        self.spriteSize = spriteSize;
        
        self.sheet = SKTexture(imageNamed: sheetImage);
    }

    /// Create a new texture from the sprite sheet cropped to a certain
    /// rectangle. This should not infer bad performance since the same
    /// object inn memory is used for the returned texture and the `in` texture
    ///  https://developer.apple.com/documentation/spritekit/sktexture/1520425-init
    func getTexture(columnIndex: Int, rowIndex: Int) throws -> SKTexture {
        
        if columnIndex < columns && rowIndex < rows {
            // Note that both the (x,y) coords and the height/width is given as
            // a percentage value [0,1]
            
            // Determine the width and height proporitions of each sprite
            let spriteWidth = self.sheet.size().width / CGFloat(self.columns)
                / self.sheet.size().width;
            let spriteHeight = self.sheet.size().height / CGFloat(self.rows)
                / self.sheet.size().height;

            let rect = CGRect(
                x: CGFloat(columnIndex) * (spriteWidth + self.spacingX),
                y: CGFloat(rowIndex) * (spriteHeight + self.spacingY),
                width: spriteWidth,
                height: spriteHeight
            )
        
            return SKTexture(rect: rect, in: self.sheet);
        }
        else {
            throw CustomError.indexOutOfRange(
                "Index outside bounds of sprite sheet: (\(columnIndex-1),\(rowIndex-1)) -- (\(self.columns-1),\(self.rows-1))"
            );
        }
        
    }

    /// Create a new sprite using the texture from the given column and
    /// row in the spritesheet. The sprite is scaled to the size passed
    /// during init() of the sprite sheet
    func getSprite(columnIndex: Int, rowIndex: Int, name: String) throws -> SKSpriteNode  {

        let sprite = SKSpriteNode(
            texture: try self.getTexture(columnIndex: columnIndex, rowIndex: rowIndex),
            size: self.spriteSize
        );
        
        sprite.name = name;
        sprite.scale(to: self.spriteSize)
        
        return sprite;
    }
}
