//
//  ImageService.h
//  GreenTravel
//
//  Created by Alex K on 8/28/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import SDWebImage;

SDWebImageCombinedOperation* loadImage(NSString *url, void (^onImageReady)(UIImage *, NSError *));
