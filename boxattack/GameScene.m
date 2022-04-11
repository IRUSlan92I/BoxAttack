#import "GameScene.h"

@implementation GameScene

@synthesize player, boxes, levels, background, scoreLabel, levelLabel, godmodeLabel;
@synthesize lastUpdateTime, pauseBeforeBoxDrop, boxDropDelay;
@synthesize score, currentLvl, godmode;

-(void)didMoveToView:(SKView *)view {
    boxes = [NSMutableArray new];
    levels = [NSMutableArray new];
    
    self.size = CGSizeMake(640, 480);
    
    background = [SKSpriteNode new];
    player = [Entity new];
    scoreLabel = [SKLabelNode new];
    levelLabel = [SKLabelNode new];
    godmodeLabel = [SKLabelNode new];
    
    [self backGrInit];
    [self playerInit];
    [self scoreLabelInit];
    [self levelLabelInit];
    [self godmodeLabelInit];
    
    for (int i = 0; i < NUMBER_OF_LVLS; i++) {
        Level *newLvl = [Level new];
        newLvl.goal = (i+1)*2;
        newLvl.delayDec = 0.5*i;
        [levels addObject:newLvl];
    }
    
    godmode = false;
    
    [self newGame];
    
    
    //-----
    SKLabelNode *test = [SKLabelNode new];
    test.fontName = @"Arial";
    test.position = CGPointMake(TILE_SIZE*2, TILE_SIZE*2);
    test.text = @"Test";
    test.fontColor = [NSColor blackColor];
    test.fontSize = 8;
    [self addChild:test];
}

-(void)backGrInit {
    background = [SKSpriteNode spriteNodeWithImageNamed:@"BG.png"];
    background.anchorPoint = CGPointMake(0, 0);
    background.position = CGPointMake(0, 0);
    [self addChild:background];
}

-(void)playerInit {
    SKTexture *playerTexture = [SKTexture textureWithImageNamed:@"Player.png"];
    player = [Entity spriteNodeWithTexture:playerTexture];
    player.anchorPoint = CGPointMake(0, 0);
    player.size = CGSizeMake(TILE_SIZE, TILE_SIZE*1.5);
    [self addChild:player];
}

-(void)scoreLabelInit {
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    scoreLabel.position = CGPointMake(TILE_SIZE, self.size.height - TILE_SIZE);
    scoreLabel.fontColor = [NSColor blackColor];
    scoreLabel.fontSize = 24;
    [self addChild:scoreLabel];
}

-(void)levelLabelInit {
    levelLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    levelLabel.position = CGPointMake(TILE_SIZE, self.size.height - TILE_SIZE*1.5);
    levelLabel.fontColor = [NSColor blackColor];
    levelLabel.fontSize = 24;
    [self addChild:levelLabel];
}

-(void)godmodeLabelInit {
    godmodeLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    godmodeLabel.hidden = true;
    godmodeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    godmodeLabel.position = CGPointMake(self.size.width - TILE_SIZE, self.size.height - TILE_SIZE);
    godmodeLabel.fontColor = [NSColor blackColor];
    godmodeLabel.fontSize = 8;
    godmodeLabel.text = @"Godmode";
    [self addChild:godmodeLabel];
}

-(void)newGame {
    currentLvl = 0;
    pauseBeforeBoxDrop = 0;
    lastUpdateTime = 0;
    boxDropDelay = 2;
    score = 0;
    player.position = CGPointMake(TILE_SIZE*5, TILE_SIZE*2);
    [player removeAllActions];
    
    for (int i = 0; i < boxes.count; i++) {
        [boxes[i] removeFromParent];
    }
    
    [boxes removeAllObjects];
}

-(void)update:(CFTimeInterval)currentTime {
    CFTimeInterval timeSinceLastUpdate = currentTime - lastUpdateTime;
    lastUpdateTime = currentTime;
    if (timeSinceLastUpdate > 1) {
        timeSinceLastUpdate = 1.0 / 60.0;
        lastUpdateTime = currentTime;
    }
    
    [player resetCollisions];
    scoreLabel.text = [NSString stringWithFormat:@"Score:\t%d", score];
    levelLabel.text = [NSString stringWithFormat:@"Level:\t%d", currentLvl+1];
    for (int i = 0; i < boxes.count; i++) {
        Entity *checkedBox = [boxes objectAtIndex:i];
        
        [checkedBox resetCollisions];
        
        [player checkCollisionWith:checkedBox];
        [checkedBox checkCollisionWith:player];
        for (int j = 0; j < boxes.count; j++) if (i != j) {
            [checkedBox checkCollisionWith:[boxes objectAtIndex:j]];
        }
        
        [checkedBox checkCollisionWithRoomWithWidth: self.size.width];
        [checkedBox fall];
        
        [self checkForPlayerIsBlockedBy: checkedBox];
    }
     
    pauseBeforeBoxDrop += timeSinceLastUpdate;
    if (pauseBeforeBoxDrop > boxDropDelay) {
        pauseBeforeBoxDrop = 0;
        boxDropDelay = [self getRandomNumberBetween:1 and:4] - ((Level *)levels[currentLvl]).delayDec;
        [self newBox];
    }
    
    [player checkCollisionWithRoomWithWidth: self.size.width];
    [player fall];
    
    [self checkForFullLine];
}

-(void)checkForPlayerIsBlockedBy:(Entity *) checkedBox {
    if (player.isBlockedFromUp) {
        if ([player actionForKey:@"jump"]) {
            [checkedBox removeFromParent];
            [boxes removeObject:checkedBox];
        }
        else {
            if (!godmode) {
                [self newGame];
            }
        }
    }
}

-(void)checkForFullLine {
    NSMutableArray *firstLine = [NSMutableArray new];
    for (int i = 0; i < boxes.count; i++) {
        Entity *checkedBox = [boxes objectAtIndex:i];
        if (lround(checkedBox.position.y) == 0) {
            if ((checkedBox.isBlockedFromDown)&&!([checkedBox actionForKey:@"afterFallIdle"])) {
                [firstLine addObject:checkedBox];
            }
        }
    }
    if (firstLine.count > 9) {
        for (int i = 0; i < firstLine.count; i++) {
            Entity *boxForDel = [firstLine objectAtIndex:i];
            [boxForDel removeFromParent];
            [boxes removeObject:boxForDel];
        }
        score++;
        if (score > ((Level *)levels[currentLvl]).goal) {
            currentLvl++;
            score = 0;
        }
    }
}

-(void)newBox {
    SKTexture *boxTexture = [SKTexture textureWithImageNamed:@"Box.png"];
    Entity *box = [Entity spriteNodeWithTexture:boxTexture];
    box.size = CGSizeMake(TILE_SIZE, TILE_SIZE);
    box.anchorPoint = CGPointMake(0, 0);
    box.position = CGPointMake(TILE_SIZE*[self getRandomNumberBetween:0 and:9], TILE_SIZE*9);
    [boxes addObject:box];
    [self addChild: [boxes lastObject]];
}

-(void)keyDown:(NSEvent *)theEvent {
    if ([theEvent modifierFlags] & NSNumericPadKeyMask) {
        
        NSString *arrow = [theEvent charactersIgnoringModifiers];
        if ([arrow length] == 1) {
            unichar keyChar = [arrow characterAtIndex: 0];
            switch (keyChar) {
                case NSLeftArrowFunctionKey:
                    [player moveLeft];
                    break;
                case NSRightArrowFunctionKey:
                    [player moveRight];
                    break;
                case NSUpArrowFunctionKey:
                    [player jump];
                    break;
            }
        }
    }
    NSString *characters = [theEvent characters];
    for (int i = 0; i < [characters length]; i++) {
        unichar c = [characters characterAtIndex: i];
        switch (c) {
            case 'a':
                [player moveLeft];
                break;
            case 'd':
                [player moveRight];
                break;
            case 'w':
            case ' ':
                [player jump];
                break;
            case 'B':
                [self newBox];
                break;
            case 'N':
                [self newGame];
                break;
            case 'G':
                godmode = !godmode;
                godmodeLabel.hidden = !godmode;
                break;
        }
    }
}

-(int)getRandomNumberBetween:(int)start and:(int)end {
    return start + arc4random()%(end-start+1);
}

@end
