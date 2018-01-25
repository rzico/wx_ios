//
//  CLDrawTool.m
//
//  Created by sho yakushiji on 2014/06/20.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLDrawTool.h"
#import "UIDevice+SystemVersion.h"

static NSString* const kCLDrawToolEraserIconName = @"eraserIconAssetsName";

@implementation CLDrawTool
{
    UIImageView *_drawingView;
    CGSize _originalImageSize;
    
    CGPoint _prevDraggingPosition;
    UIView *_menuView;
    UISlider *_colorSlider;
    UISlider *_widthSlider;
    UIView *_strokePreview;
    UIView *_strokePreviewBackground;
    UIImageView *_eraserIcon;
    
    CLToolbarMenuItem *_colorBtn;
    
    
    
}

+ (NSArray*)subtools
{
    return nil;
}

+ (NSString*)defaultTitle
{
    return [CLImageEditorTheme localizedString:@"CLDrawTool_DefaultTitle" withDefault:@"Draw"];
}

+ (BOOL)isAvailable
{
    return YES;
}

+ (CGFloat)defaultDockedNumber
{
    return 4.5;
}

#pragma mark- optional info

+ (NSDictionary*)optionalInfo
{
    return @{
             kCLDrawToolEraserIconName : @"",
             };
}

#pragma mark- implementation

- (void)setup
{
    _originalImageSize = self.editor.imageView.image.size;
    
    _drawingView = [[UIImageView alloc] initWithFrame:self.editor.imageView.bounds];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidPan:)];
    panGesture.maximumNumberOfTouches = 1;
    
    _drawingView.userInteractionEnabled = YES;
    [_drawingView addGestureRecognizer:panGesture];
    
    [self.editor.imageView addSubview:_drawingView];
    self.editor.imageView.userInteractionEnabled = YES;
    self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.editor.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.editor.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    
    _menuView = [[UIView alloc] initWithFrame:self.editor.menuView.frame];
    _menuView.backgroundColor = self.editor.menuView.backgroundColor;
    [self.editor.view addSubview:_menuView];
    
    [self setMenu];
    
    _menuView.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuView.top);
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         _menuView.transform = CGAffineTransformIdentity;
                     }];
    
}

- (void)cleanup
{
    [_drawingView removeFromSuperview];
    self.editor.imageView.userInteractionEnabled = NO;
    self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
    
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         _menuView.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuView.top);
                     }
                     completion:^(BOOL finished) {
                         [_menuView removeFromSuperview];
                     }];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });
}

#pragma mark-
- (UIImage *)createImageWithSize:(CGSize)size color:(int)color{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[self colorWithHex:color] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (UIColor *)colorWithHex:(int)hexValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0
                           alpha:1.0];
}

- (UISlider*)defaultSliderWithWidth:(CGFloat)width
{
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, width, 25)];
    
    [slider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [slider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    slider.thumbTintColor = [UIColor whiteColor];
    
    return slider;
}

- (UIImage*)colorSliderBackground
{
    CGSize size = _colorSlider.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect frame = CGRectMake(5, (size.height-10)/2, size.width-10, 5);
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:5].CGPath;
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {
        0.0f, 0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 1.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f
    };
    
    size_t count = sizeof(components)/ (sizeof(CGFloat)* 4);
    CGFloat locations[] = {0.0f, 0.9/3.0, 1/3.0, 1.5/3.0, 2/3.0, 2.5/3.0, 1.0};
    
    CGPoint startPoint = CGPointMake(5, 0);
    CGPoint endPoint = CGPointMake(size.width-5, 0);
    
    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorSpaceRef, components, locations, count);
    
    CGContextDrawLinearGradient(context, gradientRef, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    UIGraphicsEndImageContext();
    
    return tmp;
}

- (UIImage*)widthSliderBackground
{
    CGSize size = _widthSlider.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *color = [[[CLImageEditorTheme theme] toolbarTextColor] colorWithAlphaComponent:0.5];
    
    CGFloat strRadius = 1;
    CGFloat endRadius = size.height/2 * 0.6;
    
    CGPoint strPoint = CGPointMake(strRadius + 5, size.height/2 - 2);
    CGPoint endPoint = CGPointMake(size.width-endRadius - 1, strPoint.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, strPoint.x, strPoint.y, strRadius, -M_PI/2, M_PI-M_PI/2, YES);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y + endRadius);
    CGPathAddArc(path, NULL, endPoint.x, endPoint.y, endRadius, M_PI/2, M_PI+M_PI/2, YES);
    CGPathAddLineToPoint(path, NULL, strPoint.x, strPoint.y - strRadius);
    
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    CGPathRelease(path);
    
    UIGraphicsEndImageContext();
    
    return tmp;
}

- (UIColor*)colorForValue:(CGFloat)value
{
    if(value<1/3.0){
        return [UIColor colorWithWhite:value/0.3 alpha:1];
    }
    return [UIColor colorWithHue:((value-1/3.0)/0.7)*2/3.0 saturation:1 brightness:1 alpha:1];
}

- (void)setMenu
{
    CGFloat W = 30;
    CGFloat H = _menuView.height;
    if ([UIDevice isIphoneX]){
        H = _menuView.height - 34;
    }
    
    
    CGFloat x = 0;
    
    CGSize size = CGSizeMake(20, 20);
    
    NSArray *_menu = @[
                       @{@"title":@"红色",
                         @"icon":[self createImageWithSize:size color:0xff0000],
                         @"color":[self colorWithHex:0xff0000]
                         },
                       @{@"title":@"绿色",
                         @"icon":[self createImageWithSize:size color:0x00ff00],
                         @"color":[self colorWithHex:0x00ff00]
                         },
                       @{@"title":@"蓝色",
                         @"icon":[self createImageWithSize:size color:0x0000ff],
                         @"color":[self colorWithHex:0x0000ff]
                         },
                       @{@"title":@"黑色",
                         @"icon":[self createImageWithSize:size color:0x000000],
                         @"color":[self colorWithHex:0x000000]
                         },
                       ];
    
    NSInteger tag = 100;
    
    CGFloat padding = 0;
    CGFloat diff = _menuView.width / 2 - (_menu.count + 1) * W;
    
    if (0<diff){
        padding = diff / (_menu.count + 1);
    }
    
    for (NSDictionary *obj in _menu){
        CLToolbarMenuItem *view = [CLImageEditorTheme menuItemWithFrame:CGRectMake(x + padding, 0, W, H) target:self action:@selector(tappedMenu:) toolInfo:nil];
        view.tag = tag++;
        CGRect frame = view.iconView.frame;
        frame.size = size;
        view.iconView.frame = frame;
        view.iconView.backgroundColor = obj[@"color"];
        
        view.iconView.center = CGPointMake(W/2, (H - 20)/2);
        
        
        
        view.iconImage = obj[@"icon"];
        view.title = obj[@"title"];
        
        [_menuView addSubview:view];
        x += W + padding;
    }
//    _colorSlider = [self defaultSliderWithWidth:_menuView.width - W - 20];
//    _colorSlider.left = 10;
//    _colorSlider.top  = 5;
//    [_colorSlider addTarget:self action:@selector(colorSliderDidChange:) forControlEvents:UIControlEventValueChanged];
//    _colorSlider.backgroundColor = [UIColor colorWithPatternImage:[self colorSliderBackground]];
//    _colorSlider.value = 0;
//    [_menuView addSubview:_colorSlider];
//
    _widthSlider = [self defaultSliderWithWidth:0];
    _widthSlider.frame = CGRectMake(_menuView.width / 2.0 - 25, (H - 30) / 2, _menuView.width / 2 - 20, 30);
    [_widthSlider addTarget:self action:@selector(widthSliderDidChange:) forControlEvents:UIControlEventValueChanged];
    _widthSlider.value = 0.1;
    _widthSlider.backgroundColor = [UIColor colorWithPatternImage:[self widthSliderBackground]];
    [_menuView addSubview:_widthSlider];


    _strokePreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _strokePreview.layer.cornerRadius = _strokePreview.height/2;
    _strokePreview.layer.borderWidth = 1;
    _strokePreview.layer.borderColor = [[[CLImageEditorTheme theme] toolbarTextColor] CGColor];
    _strokePreview.center = CGPointMake(_menuView.width-W/2 - 10, H/2);
    [_menuView addSubview:_strokePreview];

    _strokePreviewBackground = [[UIView alloc] initWithFrame:_strokePreview.frame];
    _strokePreviewBackground.layer.cornerRadius = _strokePreviewBackground.height/2;
    _strokePreviewBackground.alpha = 0.3;
    [_strokePreviewBackground addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(strokePreviewDidTap:)]];
    [_menuView insertSubview:_strokePreviewBackground aboveSubview:_strokePreview];

    _eraserIcon = [[UIImageView alloc] initWithFrame:_strokePreview.frame];
    _eraserIcon.image  =  [self imageForKey:kCLDrawToolEraserIconName defaultImageName:@"btn_eraser.png"];
    _eraserIcon.hidden = YES;
    [_menuView addSubview:_eraserIcon];

    [self colorSliderDidChange:_colorSlider];
    [self widthSliderDidChange:_widthSlider];
    
    for (UIView *view in _menuView.subviews){
        if ([view isKindOfClass:[CLToolbarMenuItem class]]){
            if (view.tag == 100){
                CLToolbarMenuItem *defaultTool = (CLToolbarMenuItem *)view;
                [defaultTool setSelected:YES];
                [self setCurrentTool:defaultTool];
                break;
            }
        }
    }
    _menuView.clipsToBounds = NO;
}

- (void)setCurrentTool:(CLToolbarMenuItem *)item{
    _strokePreview.backgroundColor = item.iconView.backgroundColor;
    _strokePreviewBackground.backgroundColor = [self colorWithHex:0xbbbbbb];
    _widthSlider.thumbTintColor = item.iconView.backgroundColor;
//    _colorSlider.thumbTintColor = _strokePreview.backgroundColor;
}

- (void)tappedMenu:(UITapGestureRecognizer *)sender{
    static BOOL inProgress = NO;
    
    if(inProgress){ return; }
    
    CLToolbarMenuItem *view = sender.view;
    if(_eraserIcon.hidden){
        for (UIView *subview in view.superview.subviews){
            if ([subview isKindOfClass:[CLToolbarMenuItem class]]){
                if (![subview isEqual:view]){
                    [(CLToolbarMenuItem *)subview setSelected:NO];
                }
            }
        }
        
        view.alpha = 0.2;
        inProgress = YES;
        [UIView animateWithDuration:kCLImageToolAnimationDuration
                         animations:^{
                             view.alpha = 1;
                             inProgress = NO;
                             [view setSelected:YES];
                             [self setCurrentTool:view];
                         }
         ];
    }else{
        for (UIView *subview in view.superview.subviews){
            if ([subview isKindOfClass:[CLToolbarMenuItem class]]){
                [(CLToolbarMenuItem *)subview setSelected:NO];
            }
        }
    }
}

- (void)colorSliderDidChange:(UISlider*)sender
{
    if(_eraserIcon.hidden){
        _strokePreview.backgroundColor = [self colorForValue:_colorSlider.value];
        _strokePreviewBackground.backgroundColor = _strokePreview.backgroundColor;
        _colorSlider.thumbTintColor = _strokePreview.backgroundColor;
    }
}

- (void)widthSliderDidChange:(UISlider*)sender
{
    CGFloat scale = MAX(0.05, _widthSlider.value);
    _strokePreview.transform = CGAffineTransformMakeScale(scale, scale);
    _strokePreview.layer.borderWidth = 2/scale;
}

- (void)strokePreviewDidTap:(UITapGestureRecognizer*)sender
{
    _eraserIcon.hidden = !_eraserIcon.hidden;
    
    if (!_eraserIcon.hidden){
        for (UIView *subview in sender.view.superview.subviews){
            if ([subview isKindOfClass:[CLToolbarMenuItem class]]){
                [(CLToolbarMenuItem *)subview setSelected:NO];
            }
        }
    }
    
    if(_eraserIcon.hidden){
        [self colorSliderDidChange:_colorSlider];
    }
    else{
        _strokePreview.backgroundColor = [[CLImageEditorTheme theme] toolbarTextColor];
        _strokePreviewBackground.backgroundColor = _strokePreview.backgroundColor;
    }
}

- (void)drawingViewDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint currentDraggingPosition = [sender locationInView:_drawingView];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _prevDraggingPosition = currentDraggingPosition;
    }
    
    if(sender.state != UIGestureRecognizerStateEnded){
        [self drawLine:_prevDraggingPosition to:currentDraggingPosition];
    }
    _prevDraggingPosition = currentDraggingPosition;
}

-(void)drawLine:(CGPoint)from to:(CGPoint)to
{
    CGSize size = _drawingView.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [_drawingView.image drawAtPoint:CGPointZero];
    
    CGFloat strokeWidth = MAX(1, _widthSlider.value * 65);
    UIColor *strokeColor = _strokePreview.backgroundColor;
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    if(!_eraserIcon.hidden){
        CGContextSetBlendMode(context, kCGBlendModeClear);
    }
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
    
    _drawingView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

- (UIImage*)buildImage
{
    UIGraphicsBeginImageContextWithOptions(_originalImageSize, NO, self.editor.imageView.image.scale);
    
    [self.editor.imageView.image drawAtPoint:CGPointZero];
    [_drawingView.image drawInRect:CGRectMake(0, 0, _originalImageSize.width, _originalImageSize.height)];
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tmp;
}

@end
