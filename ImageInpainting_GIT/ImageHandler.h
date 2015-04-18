//
//  ImageHandler.h
//  ImageInpainting
//
//  Created by 钟路成 on 15/4/8.
//  Copyright (c) 2015年 钟路成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectedRegion.h"
#import <UIKit/UIKit.h>
#import "PixelInfo.h"

@interface ImageHandler : NSObject

- (UIImage*)recaculateImage:(UIImage*)sourceImage MaskRegion:(SelectedRegion*)region;
@end
