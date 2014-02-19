//
//  JWCColliderType.h
//  Cliche Fantasy Game
//
//  Created by Jeff Schwab on 2/18/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#ifndef Cliche_Fantasy_Game_JWCColliderType_h
#define Cliche_Fantasy_Game_JWCColliderType_h

typedef enum : uint8_t {
    JWCColliderTypeHero             = 1,
    JWCColliderTypeWall             = 8,
    JWCColliderTypeMushroom         = 16,
    JWCColliderTypeDoor             = 32
} JWCColliderType;

#endif
