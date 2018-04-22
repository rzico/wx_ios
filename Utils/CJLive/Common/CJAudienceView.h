//
//  CJAudienceView.h
//  Weex
//
//  Created by 郭书智 on 2018/4/4.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CJAudienceViewDelegate<NSObject>
    
@optional
    
- (void)CJAudienceViewOnClickAudienceLabel;
    
@end

@interface CJAudienceView : UIView

@property (nonatomic, strong) UILabel *audienceLabel;
    
- (void)setAudience:(NSInteger)count;
    
@property (nonatomic, strong) id<CJAudienceViewDelegate> delegate;
    
@end
