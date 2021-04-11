//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JGProgressHUD/JGProgressHUD.h>

@interface JQCV : NSObject

+ (UIImage *) getSharpenedImage:(UIImage *)image;
+ (UIImage *) getGrayImage:(UIImage *)image;
+ (UIImage *) getPreProcessResult:(UIImage *)image :(UIImage *)mask :(CGFloat)middleSeperator :(CGPoint)p_UL :(CGPoint)p_UR :(CGPoint)p_DL :(CGPoint)p_DR :(NSInteger)p_Width :(NSInteger)p_Height :(NSInteger)segment_count :(JGProgressHUD *)progressHUD;
+ (UIImage *) getGaussianImage:(UIImage *)image;
+ (UIImage *) getSobelImage:(UIImage *)image;
+ (UIImage *) getSobelXImage:(UIImage *)image;
+ (UIImage *) getSobelYImage:(UIImage *)image;
+ (UIImage *) getNotatedImage:(UIImage *)image :(CGPoint)p_UL :(CGPoint)p_UR :(CGPoint)p_DL :(CGPoint)p_DR :(CGFloat) seperatorThreshold;
+ (UIImage *) getResizedImage:(UIImage *)image :(CGSize) resize :(bool)withAlpha;
+ (UIImage *) getImage:(UIImage *)image :(bool)withAlpha;
+ (NSMutableArray *) largestRect:(UIImage *)image;

@end
