#import <SpriteKit/SpriteKit.h>
#import "sceneParam.c"

@interface Entity : SKSpriteNode
{
    @private
    BOOL isBlockedFromLeft;
    BOOL isBlockedFromRight;
    BOOL isBlockedFromUp;
    BOOL isBlockedFromDown;
    Entity *blockedFromLeftBy;
    Entity *blockedFromRightBy;
    Entity *blockedFromUpBy;
    Entity *blockedFromDownBy;
}
@property BOOL isBlockedFromLeft;
@property BOOL isBlockedFromRight;
@property BOOL isBlockedFromUp;
@property BOOL isBlockedFromDown;
@property Entity *blockedFromLeftBy;
@property Entity *blockedFromRightBy;
@property Entity *blockedFromUpBy;
@property Entity *blockedFromDownBy;

-(void)resetCollisions;
-(void)checkCollisionWith:(Entity *) secondEntity;
-(void)checkCollisionWithRoomWithWidth:(CGFloat)roomWidth;

-(void)moveLeft;
-(void)moveRight;
-(void)fall;
-(void)jump;

@end
