//
//  ImageHandler.m
//  ImageInpainting
//
//  Created by 钟路成 on 15/4/8.
//  Copyright (c) 2015年 钟路成. All rights reserved.
//

#import "ImageHandler.h"

@implementation ImageHandler
void ProviderReleaseData (void *info, const void *data, size_t size)
{
    free((void*)data);
}
- (UIImage*)recaculateImage:(UIImage*)sourceImage MaskRegion:(SelectedRegion*)region{
    UIImage* resultImage;
    
    //malloc memory
    const int imageWidth = sourceImage.size.width;
    const int imageHeight = sourceImage.size.height;
    
    if(imageHeight!=region.height || imageWidth!=region.width){
        return nil;
    }
    
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    // creat context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), sourceImage.CGImage);
    
    // get pixels info
    //int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    PixelInfo *pi = [PixelInfo new];
    [pi recalculateColor:pCurPtr Region:region];
    /*
     Range tempRange;
     for(NSInteger i=0;i<region.height;i++){
     //for(int k=0;k<[region.rangeOfRows[i] count];k++){
     NSMutableArray* rangeOfEach = region.rangeOfRows[i];
     for(int p=0;p<[rangeOfEach count];p++){
     NSValue* eachRange = rangeOfEach[p];
     [eachRange getValue:&tempRange];
     for(NSInteger j=tempRange.startPosition;j<=tempRange.endPosition;j++){
     //uint8_t* ptr = (uint8_t*)(pCurPtr[i*region.width + j]);
     pCurPtr[i*region.width + j]=0;
     //uint8_t* ptr = (uint8_t*)(pCurPtr[j]);
     //ptr[3] = 0; //0~255
     // ptr[2] = 0;
     //ptr[1] = 0;
     }
     }
     //}
     }
     */
    
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    resultImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultImage;
}

@end
