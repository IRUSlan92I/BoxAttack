#import "Entity.h"

@implementation Entity

@synthesize isBlockedFromLeft, isBlockedFromRight, isBlockedFromUp, isBlockedFromDown;
@synthesize blockedFromLeftBy, blockedFromRightBy, blockedFromUpBy, blockedFromDownBy;

-(void)resetCollisions {
    self.isBlockedFromLeft = self.isBlockedFromRight = self.isBlockedFromUp = self.isBlockedFromDown = false;
    self.blockedFromLeftBy = self.blockedFromRightBy = self.blockedFromUpBy = self.blockedFromDownBy = nil;
}

-(void)checkCollisionWith:(Entity *)secondEntity {
    if ((lround(self.position.x - secondEntity.size.width-1) < lround(secondEntity.position.x))&&
        (lround(self.position.x - secondEntity.size.width+1) > lround(secondEntity.position.x))) {
        if ((lround(self.position.y + secondEntity.size.height) > lround(secondEntity.position.y))&&
            ((lround(self.position.y - secondEntity.size.height) < lround(secondEntity.position.y)))) {
            self.isBlockedFromLeft = true;
            blockedFromLeftBy = secondEntity;
        }
    }
    if ((lround(self.position.x + self.size.width-1) < lround(secondEntity.position.x))&&
        (lround(self.position.x + self.size.width+1) > lround(secondEntity.position.x))) {
        if ((lround(self.position.y + secondEntity.size.height) > lround(secondEntity.position.y))&&
            ((lround(self.position.y - secondEntity.size.height) < lround(secondEntity.position.y))))
        {
            self.isBlockedFromRight = true;
            blockedFromRightBy = secondEntity;
        }
    }
    if ((lround(self.position.x - self.size.width) < lround(secondEntity.position.x))&&
        (lround(self.position.x + self.size.width) > (secondEntity.position.x))) {
        if ((lround(self.position.y + self.size.height*0.75) < lround(secondEntity.position.y))&&
            (lround(self.position.y + self.size.height+1) > lround(secondEntity.position.y))) {
            self.isBlockedFromUp = true;
            blockedFromUpBy = secondEntity;
        }
    }
    if ((lround(self.position.x - self.size.width+1) < lround(secondEntity.position.x))&&
        (lround(self.position.x + self.size.width-1) > (secondEntity.position.x))) {
        if ((lround(self.position.y - secondEntity.size.height-1) <= lround(secondEntity.position.y))&&
            (lround(self.position.y - secondEntity.size.height+1) >= lround(secondEntity.position.y))) {
            self.isBlockedFromDown = true;
            blockedFromDownBy = secondEntity;
        }
    }
}

-(void)checkCollisionWithRoomWithWidth:(CGFloat)roomWidth {
    if (lround(self.position.x) == 0) {
        self.isBlockedFromLeft = true;
    }
    if (lround(self.position.x) == lround(roomWidth - TILE_SIZE)) {
        self.isBlockedFromRight = true;
    }
    if (lround(self.position.y) == 0) {
        self.isBlockedFromDown = true;
    }
}

-(void)moveLeft {
    if (![self actionForKey:@"move"]) {
        SKAction *moveLeft = [SKAction moveByX:-TILE_SIZE y:0 duration: (self.isBlockedFromLeft) ? 0.7 : 0.4];
        if ((!self.isBlockedFromLeft)||
            (!(self.blockedFromRightBy.isBlockedFromLeft)&&(!self.blockedFromRightBy.isBlockedFromUp))) {
            [self runAction:moveLeft withKey:@"move"];
            [self.blockedFromLeftBy runAction:moveLeft];
        }
    }
}

-(void)moveRight {
    if (![self actionForKey:@"move"]) {
        SKAction *moveRight = [SKAction moveByX:+TILE_SIZE y:0 duration: (self.isBlockedFromRight) ? 0.7 : 0.4];
        if ((!self.isBlockedFromRight)||
            (!(self.blockedFromRightBy.isBlockedFromRight)&&(!self.blockedFromRightBy.isBlockedFromUp))) {
            [self runAction:moveRight withKey:@"move"];
            [self.blockedFromRightBy runAction:moveRight];
        }
    }
}

-(void)fall {
    if (!self.isBlockedFromDown) {
        SKAction *fall = [SKAction moveByX:0 y:-TILE_SIZE*0.5 duration:0.1];
        SKAction *idle = [SKAction moveByX:0 y:0 duration:0.4];
        if ((![self actionForKey:@"fall"])&&(![self actionForKey:@"jump"])) {
            [self runAction:fall withKey:@"fall"];
            [self runAction:idle withKey:@"afterFallIdle"];
        }
    }
}

-(void)jump {
    if (self.isBlockedFromDown) {
        SKAction *jump = [SKAction moveByX:0 y:+TILE_SIZE*1.5 duration:0.15];
        SKAction *pauseAfterJump = [SKAction moveByX:0 y:0 duration:0.2];
        if (![self actionForKey:@"jump"]) {
            [self runAction:jump];
            [self runAction:pauseAfterJump withKey:@"jump"];
        }
    }
}

@end
