//
//  MainView.h
//  ImageInpainting
//
//  Created by 钟路成 on 15/4/6.
//  Copyright (c) 2015年 钟路成. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectedRegion.h"
#import "ImageHandler.h"

@interface MainView : UIView
@property UIImage * myImage;
@property SelectedRegion* regionInfo;

- (UIImage*)recaculateImage:(UIImage*) sourceImage MaskRegion:(SelectedRegion*) region;
@end
