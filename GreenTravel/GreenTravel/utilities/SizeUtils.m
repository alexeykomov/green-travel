//
//  Size.m
//  GreenTravel
//
//  Created by Alex K on 8/19/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "SizeUtils.h"

static const CGFloat kCellAspectRatio = 324.0 / 144.0;

CGSize getCellSize(CGSize inputSize) {
    return CGSizeMake(inputSize.width, inputSize.width / kCellAspectRatio);
};
