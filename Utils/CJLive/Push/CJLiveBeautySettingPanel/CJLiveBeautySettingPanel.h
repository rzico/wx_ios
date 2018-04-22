//
//  CJLiveBeautySettingPanel.h
//  Weex
//
//  Created by 郭书智 on 2018/4/4.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CJFilterType){
    CJFilterType_None   = 0,
    CJFilterType_White,
    CJFilterType_Langman,
    CJFilterType_Qingxin,
    CJFilterType_Weimei,
    CJFilterType_Fennen,
    CJFilterType_Huaijiu,
    CJFilterType_Landiao,
    CJFilterType_Qingliang,
    CJFilterType_Rixi,
};

@protocol CJLiveBeautySettingPanelDelegate <NSObject>
- (void)onSetBeautyStyle:(int)beautyStyle beautyLevel:(float)beautyLevel whitenessLevel:(float)whitenessLevel ruddinessLevel:(float)ruddinessLevel;
- (void)onSetMixLevel:(float)mixLevel;
- (void)onSetEyeScaleLevel:(float)eyeScaleLevel;
- (void)onSetFaceScaleLevel:(float)faceScaleLevel;
//- (void)onSetFaceBeautyLevel:(float)beautyLevel;
- (void)onSetFaceVLevel:(float)vLevel;
- (void)onSetChinLevel:(float)chinLevel;
- (void)onSetFaceShortLevel:(float)shortLevel;
- (void)onSetNoseSlimLevel:(float)slimLevel;
- (void)onSetFilter:(UIImage*)filterImage;
- (void)onSetGreenScreenFile:(NSURL *)file;
- (void)onSelectMotionTmpl:(NSString *)tmplName inDir:(NSString *)tmplDir;

@end

@interface CJLiveBeautySettingPanel : UIView

@property (nonatomic, weak) id<CJLiveBeautySettingPanelDelegate> delegate;

- (void)resetValues;
- (void)trigglerValues;
+ (NSUInteger)getHeight;
- (void)changeFunction:(NSInteger)i;

@end
