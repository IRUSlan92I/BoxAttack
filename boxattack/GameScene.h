#import <SpriteKit/SpriteKit.h>
#import "Entity.h"
#import "Level.h"
#import "sceneParam.c"

@interface GameScene : SKScene
{
    Entity *player;
    NSMutableArray *boxes;
    SKSpriteNode *background;
    SKLabelNode *scoreLabel;
    SKLabelNode *levelLabel;
    CFTimeInterval lastUpdateTime;
    CFTimeInterval pauseBeforeBoxDrop;
    CFTimeInterval boxDropDelay;
    int score;
    NSMutableArray *levels;
    int currentLvl;
    BOOL godmode;
    SKLabelNode *godmodeLabel;
}
@property Entity *player;
@property NSMutableArray *boxes;
@property SKSpriteNode *background;
@property SKLabelNode *scoreLabel;
@property SKLabelNode *levelLabel;
@property CFTimeInterval lastUpdateTime;
@property CFTimeInterval pauseBeforeBoxDrop;
@property CFTimeInterval boxDropDelay;
@property int score;
@property NSMutableArray *levels;
@property int currentLvl;
@property BOOL godmode;
@property SKLabelNode *godmodeLabel;

-(void)backGrInit;
-(void)playerInit;
-(void)scoreLabelInit;
-(void)levelLabelInit;
-(void)godmodeLabelInit;

-(void)newGame;
-(void)newBox;
-(int)getRandomNumberBetween:(int)start and:(int)end;
-(void)checkForPlayerIsBlockedBy:(Entity *) checkedBox;
-(void)checkForFullLine;

@end
