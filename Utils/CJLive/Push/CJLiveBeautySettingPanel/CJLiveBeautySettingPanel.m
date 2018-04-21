//
//  CJLiveBeautySettingPanel.m
//  Weex
//
//  Created by 郭书智 on 2018/4/4.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLiveBeautySettingPanel.h"
#import "CJTextCell.h"

#define CJBeautyViewMargin 15
#define CJBeautyViewSliderHeight 30
#define CJBeautyViewCollectionHeight 50
#define CJBeautyViewTitleWidth 40

@interface CJLiveBeautySettingPanel() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *functionCollectionView;
@property (nonatomic, strong) UICollectionView *styleCollectionView;
@property (nonatomic, strong) UICollectionView *beautyCollectionView;
@property (nonatomic, strong) UICollectionView *filterCollectionView;

@property (nonatomic, strong) NSMutableArray *functionArray;
@property (nonatomic, strong) NSMutableArray *styleArray;
@property (nonatomic, strong) NSMutableArray *beautyArray;
@property (nonatomic, strong) NSMutableArray *filterArray;

@property (nonatomic, strong) NSIndexPath *selectFunctionIndexPath;
@property (nonatomic, strong) NSIndexPath *selectStyleIndexPath;
@property (nonatomic, strong) NSIndexPath *selectBeautyIndexPath;
@property (nonatomic, strong) NSIndexPath *selectFilterIndexPath;

@property (nonatomic, strong) UILabel *beautyLabel;
@property (nonatomic, strong) UISlider *beautySlider;
@property (nonatomic, strong) NSMutableDictionary *beautyValueMap;

@property (nonatomic, strong) UILabel *filterLabel;
@property (nonatomic, strong) UISlider *filterSlider;


@property (nonatomic, strong) NSMutableDictionary *cellCacheForWidth;

@property (nonatomic, assign) CGFloat beautyLevel;
@property (nonatomic, assign) CGFloat whiteLevel;
@property (nonatomic, assign) CGFloat ruddyLevel;

@end

@implementation CJLiveBeautySettingPanel

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews{
    self.beautySlider.frame = CGRectMake(CJBeautyViewMargin * 4, CJBeautyViewMargin, self.frame.size.width - 10 * CJBeautyViewMargin - CJBeautyViewSliderHeight, CJBeautyViewSliderHeight);
    [self addSubview:self.beautySlider];
    
    self.beautyLabel.frame = CGRectMake(self.beautySlider.frame.size.width + self.beautySlider.frame.origin.x + CJBeautyViewMargin, CJBeautyViewMargin, CJBeautyViewSliderHeight, CJBeautyViewSliderHeight);
    self.beautyLabel.layer.cornerRadius = self.beautyLabel.frame.size.width / 2;
    self.beautyLabel.layer.masksToBounds = YES;
    [self addSubview:self.beautyLabel];
    
    self.filterSlider.frame = CGRectMake(CJBeautyViewMargin * 4, CJBeautyViewMargin, self.frame.size.width - 10 * CJBeautyViewMargin - CJBeautyViewSliderHeight, CJBeautyViewSliderHeight);
    self.filterSlider.hidden = YES;
    [self addSubview:self.filterSlider];
    
    self.filterLabel.frame = CGRectMake(self.filterSlider.frame.size.width + self.filterSlider.frame.origin.x + CJBeautyViewMargin, CJBeautyViewMargin, CJBeautyViewSliderHeight, CJBeautyViewSliderHeight);
    self.filterLabel.layer.cornerRadius = self.filterLabel.frame.size.width / 2;
    self.filterLabel.layer.masksToBounds = YES;
    self.filterLabel.hidden = YES;
    [self addSubview:self.filterLabel];
    
    self.beautyCollectionView.frame = CGRectMake(0, self.beautySlider.frame.size.height + self.beautySlider.frame.origin.y + CJBeautyViewMargin, self.frame.size.width, CJBeautyViewSliderHeight * 2 + 2 * CJBeautyViewMargin);
    [self addSubview:self.beautyCollectionView];
    
    self.styleCollectionView.frame = CGRectMake(0, self.beautySlider.frame.size.height + self.beautySlider.frame.origin.y + CJBeautyViewMargin, self.frame.size.width, CJBeautyViewSliderHeight * 2 + 2 * CJBeautyViewMargin);
    self.styleCollectionView.hidden = YES;
    [self addSubview:self.styleCollectionView];
    
    self.filterCollectionView.frame = CGRectMake(0, self.beautySlider.frame.size.height + self.beautySlider.frame.origin.y + CJBeautyViewMargin, self.frame.size.width, CJBeautyViewSliderHeight * 2 + 2 * CJBeautyViewMargin);
    self.filterCollectionView.hidden = YES;
    [self addSubview:self.filterCollectionView];
    
    self.functionCollectionView.frame = CGRectMake(0, self.beautyCollectionView.frame.size.height + self.beautyCollectionView.frame.origin.y, self.frame.size.width, CJBeautyViewCollectionHeight);
    [self addSubview:self.functionCollectionView];
}

#pragma mark - collection
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == self.functionCollectionView){
        return self.functionArray.count;
    }else if (collectionView == self.styleCollectionView){
        return self.styleArray.count;
    }else if (collectionView == self.beautyCollectionView){
        return self.beautyArray.count;
    }else if (collectionView == self.filterCollectionView){
        return self.filterArray.count;
    }else{
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.functionCollectionView){
        CJTextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CJTextCell reuseIdentifier] forIndexPath:indexPath];
        cell.label.text = self.functionArray[indexPath.row];
        [cell setSelected:(self.selectFunctionIndexPath.row == indexPath.row)];
        return cell;
    }else if (collectionView == self.styleCollectionView){
        CJTextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CJTextCell reuseIdentifier] forIndexPath:indexPath];
        cell.label.text = self.styleArray[indexPath.row];
        [cell setSelected:(self.selectStyleIndexPath.row == indexPath.row)];
        return cell;
    }else if (collectionView == self.beautyCollectionView){
        CJTextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CJTextCell reuseIdentifier] forIndexPath:indexPath];
        cell.label.text = self.beautyArray[indexPath.row];
        [cell setSelected:(self.selectBeautyIndexPath.row == indexPath.row)];
        return cell;
    }else if (collectionView == self.filterCollectionView){
        CJTextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CJTextCell reuseIdentifier] forIndexPath:indexPath];
        cell.label.text = self.filterArray[indexPath.row];
        [cell setSelected:(self.selectFilterIndexPath.row == indexPath.row)];
        return cell;
    }else{
        return [collectionView dequeueReusableCellWithReuseIdentifier:[CJTextCell reuseIdentifier] forIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.functionCollectionView){
        CJTextCell *cell = (CJTextCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (indexPath.row != self.selectFunctionIndexPath.row){
            [cell setSelected:true];
            CJTextCell *selectCell = (CJTextCell *)[collectionView cellForItemAtIndexPath:self.selectFunctionIndexPath];
            [selectCell setSelected:false];
            self.selectFunctionIndexPath = indexPath;
            [self changeFunction:indexPath.row];
        }
    }else if (collectionView == self.styleCollectionView){
        CJTextCell *cell = (CJTextCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (indexPath.row != self.selectStyleIndexPath.row){
            [cell setSelected:true];
            CJTextCell *selectCell = (CJTextCell *)[collectionView cellForItemAtIndexPath:self.selectStyleIndexPath];
            [selectCell setSelected:false];
            self.selectStyleIndexPath = indexPath;
            [self onValueChanged:self.beautySlider];
        }
    }else if (collectionView == self.beautyCollectionView){
        CJTextCell *cell = (CJTextCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (indexPath.row != self.selectBeautyIndexPath.row){
            [cell setSelected:true];
            CJTextCell *selectCell = (CJTextCell *)[collectionView cellForItemAtIndexPath:self.selectBeautyIndexPath];
            [selectCell setSelected:false];
            self.selectBeautyIndexPath = indexPath;
            if (self.selectBeautyIndexPath.row == 6){
                //下巴
                self.beautySlider.minimumValue = -10;
                self.beautySlider.maximumValue = 10;
            }else{
                self.beautySlider.minimumValue = 0;
                self.beautySlider.maximumValue = 10;
            }
            float value = [[self.beautyValueMap objectForKey:[NSNumber numberWithInteger:self.selectBeautyIndexPath.row]] floatValue];
            self.beautyLabel.text = [NSString stringWithFormat:@"%d",(int)value];
            [self.beautySlider setValue:value];
        }
    }else if (collectionView == self.filterCollectionView){
        CJTextCell *cell = (CJTextCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if(indexPath.row != self.selectFilterIndexPath.row){
            [cell setSelected:YES];
            CJTextCell *selectCell = (CJTextCell *)[collectionView cellForItemAtIndexPath:self.selectFilterIndexPath];
            [selectCell setSelected:NO];
            self.selectFilterIndexPath = indexPath;
            [self onSetFilterWithIndex:indexPath.row];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [CJTextCell reuseIdentifier];
    NSString *text = nil;
    if (collectionView == self.functionCollectionView){
        text = self.functionArray[indexPath.row];
    }else if (collectionView == self.styleCollectionView){
        text = self.styleArray[indexPath.row];
    }else if (collectionView == self.beautyCollectionView){
        text = self.beautyArray[indexPath.row];
    }else if (collectionView == self.filterCollectionView){
        text = self.filterArray[indexPath.row];
    }
    CJTextCell *cell = [self.cellCacheForWidth objectForKey:identifier];
    if(!cell){
        cell = [[CJTextCell alloc] init];
        [self.cellCacheForWidth setObject:cell forKey:identifier];
    }
    NSDictionary *attrs = @{NSFontAttributeName : cell.label.font};
    CGSize size=[text sizeWithAttributes:attrs];;
    return CGSizeMake(size.width + 2 * CJBeautyViewMargin, collectionView.frame.size.height);
}



- (void)changeFunction:(NSInteger)index{
    self.styleCollectionView.hidden = index == 0 ? false : true;
    self.beautyCollectionView.hidden = index == 1 ? false : true;
    self.filterCollectionView.hidden = index == 2 ? false : true;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    CJTextCell *selectCell = (CJTextCell *)[self.functionCollectionView cellForItemAtIndexPath:self.selectFunctionIndexPath];
    [selectCell setSelected:false];
    CJTextCell *cell = (CJTextCell *)[self.functionCollectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:true];
    self.selectFunctionIndexPath = indexPath;
}

- (void)onValueChanged:(id)sender{
    UISlider *slider = (UISlider *)sender;
    if (slider == self.filterSlider){
        self.filterLabel.text = [NSString stringWithFormat:@"%d",(int)self.filterSlider.value];
        if([self.delegate respondsToSelector:@selector(onSetMixLevel:)]){
            [self.delegate onSetMixLevel:self.filterSlider.value];
        }
    }else{
        [self.beautyValueMap setObject:[NSNumber numberWithFloat:self.beautySlider.value] forKey:[NSNumber numberWithInteger:self.selectBeautyIndexPath.row]];
        self.beautyLabel.text = [NSString stringWithFormat:@"%d",(int)self.beautySlider.value];
        
        if(self.selectBeautyIndexPath.row == 0){
            if([self.delegate respondsToSelector:@selector(onSetBeautyStyle:beautyLevel:whitenessLevel:ruddinessLevel:)]){
                _beautyLevel = self.beautySlider.value;
                [self.delegate onSetBeautyStyle:(int)self.selectStyleIndexPath.row beautyLevel:_beautyLevel whitenessLevel:_whiteLevel ruddinessLevel:_ruddyLevel];
            }
        }
        else if(self.selectBeautyIndexPath.row == 1){
            if([self.delegate respondsToSelector:@selector(onSetBeautyStyle:beautyLevel:whitenessLevel:ruddinessLevel:)]){
                _whiteLevel = self.beautySlider.value;
                [self.delegate onSetBeautyStyle:(int)self.selectStyleIndexPath.row beautyLevel:_beautyLevel whitenessLevel:_whiteLevel ruddinessLevel:_ruddyLevel];
            }
        }
        else if(self.selectBeautyIndexPath.row == 2){
            if([self.delegate respondsToSelector:@selector(onSetBeautyStyle:beautyLevel:whitenessLevel:ruddinessLevel:)]){
                _ruddyLevel = self.beautySlider.value;
                [self.delegate onSetBeautyStyle:(int)self.selectStyleIndexPath.row beautyLevel:_beautyLevel whitenessLevel:_whiteLevel ruddinessLevel:_ruddyLevel];
            }
        }
        else if(self.selectBeautyIndexPath.row == 3){
            if([self.delegate respondsToSelector:@selector(onSetEyeScaleLevel:)]){
                [self.delegate onSetEyeScaleLevel:self.beautySlider.value];
            }
        }
        else if(self.selectBeautyIndexPath.row == 4){
            if([self.delegate respondsToSelector:@selector(onSetFaceScaleLevel:)]){
                [self.delegate onSetFaceScaleLevel:self.beautySlider.value];
            }
        }else if(self.selectBeautyIndexPath.row == 5){
            if([self.delegate respondsToSelector:@selector(onSetFaceVLevel:)]){
                [self.delegate onSetFaceVLevel:self.beautySlider.value];
            }
        }
        else if(self.selectBeautyIndexPath.row == 6){
            if([self.delegate respondsToSelector:@selector(onSetChinLevel:)]){
                [self.delegate onSetChinLevel:self.beautySlider.value];
            }
        }
        else if(self.selectBeautyIndexPath.row == 7){
            if([self.delegate respondsToSelector:@selector(onSetFaceShortLevel:)]){
                [self.delegate onSetFaceShortLevel:self.beautySlider.value];
            }
        }
        else if(self.selectBeautyIndexPath.row == 8){
            if([self.delegate respondsToSelector:@selector(onSetNoseSlimLevel:)]){
                [self.delegate onSetNoseSlimLevel:self.beautySlider.value];
            }
        }
        else{
            
        }
    }
}

- (void)onSetFilterWithIndex:(NSInteger)index{
    if ([self.delegate respondsToSelector:@selector(onSetFilter:)]) {
        NSString* lookupFileName = @"";
        switch (index) {
            case 0:
                break;
            case 1:
                lookupFileName = @"white.png";
                break;
            case 2:
                lookupFileName = @"langman.png";
                break;
            case 3:
                lookupFileName = @"qingxin.png";
                break;
            case 4:
                lookupFileName = @"weimei.png";
                break;
            case 5:
                lookupFileName = @"fennen.png";
                break;
            case 6:
                lookupFileName = @"huaijiu.png";
                break;
            case 7:
                lookupFileName = @"landiao.png";
                break;
            case 8:
                lookupFileName = @"qingliang.png";
                break;
            case 9:
                lookupFileName = @"rixi.png";
                break;
            default:
                break;
        }
        NSString * path = [[NSBundle mainBundle] pathForResource:@"FilterResource" ofType:@"bundle"];
        if (path != nil && index != CJFilterType_None) {
            path = [path stringByAppendingPathComponent:lookupFileName];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [self.delegate onSetFilter:image];
            
        } else {
            [self.delegate onSetFilter:nil];
        }
    }
}

#pragma mark - height
+ (NSUInteger)getHeight{
    return CJBeautyViewMargin * 4 + 3 * CJBeautyViewSliderHeight + CJBeautyViewCollectionHeight;
}

#pragma mark - lazy load

- (NSMutableArray *)functionArray{
    if(!_functionArray){
        _functionArray = [[NSMutableArray alloc] init];
        [_functionArray addObject:@"风格"];
        [_functionArray addObject:@"美颜"];
        [_functionArray addObject:@"滤镜"];
    }
    return _functionArray;
}


- (NSMutableArray *)filterArray{
    if (!_filterArray){
        _filterArray = [[NSMutableArray alloc] init];
        [_filterArray addObject:@"清除"];
        [_filterArray addObject:@"美白"];
        [_filterArray addObject:@"浪漫"];
        [_filterArray addObject:@"清新"];
        [_filterArray addObject:@"唯美"];
        [_filterArray addObject:@"粉嫩"];
        [_filterArray addObject:@"怀旧"];
        [_filterArray addObject:@"蓝调"];
        [_filterArray addObject:@"清亮"];
        [_filterArray addObject:@"日系"];
    }
    return _filterArray;
}

- (NSMutableArray *)beautyArray{
    if(!_beautyArray){
        _beautyArray = [[NSMutableArray alloc] init];
        [_beautyArray addObject:@"美颜"];
        [_beautyArray addObject:@"美白"];
        [_beautyArray addObject:@"红润"];
        [_beautyArray addObject:@"大眼"];
        [_beautyArray addObject:@"瘦脸"];
        [_beautyArray addObject:@"v脸"];
        [_beautyArray addObject:@"下巴"];
        [_beautyArray addObject:@"短脸"];
        [_beautyArray addObject:@"瘦鼻"];
    }
    return _beautyArray;
}

- (NSMutableArray *)styleArray{
    if(!_styleArray){
        _styleArray = [[NSMutableArray alloc] init];
        [_styleArray addObject:@"光滑"];
        [_styleArray addObject:@"自然"];
//        [_styleArray addObject:@"p图"];
    }
    return _styleArray;
}

- (NSMutableDictionary *)beautyValueMap{
    if(!_beautyValueMap){
        _beautyValueMap = [[NSMutableDictionary alloc] init];
    }
    return _beautyValueMap;
}

- (UICollectionView *)functionCollectionView{
    if(!_functionCollectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _functionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _functionCollectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _functionCollectionView.showsHorizontalScrollIndicator = NO;
        _functionCollectionView.delegate = self;
        _functionCollectionView.dataSource = self;
        [_functionCollectionView registerClass:[CJTextCell class] forCellWithReuseIdentifier:[CJTextCell reuseIdentifier]];
    }
    return _functionCollectionView;
}

- (UICollectionView *)styleCollectionView{
    if(!_styleCollectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _styleCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _styleCollectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _styleCollectionView.showsHorizontalScrollIndicator = NO;
        _styleCollectionView.delegate = self;
        _styleCollectionView.dataSource = self;
        [_styleCollectionView registerClass:[CJTextCell class] forCellWithReuseIdentifier:[CJTextCell reuseIdentifier]];
    }
    return _styleCollectionView;
}

- (UICollectionView *)filterCollectionView{
    if(!_filterCollectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _filterCollectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _filterCollectionView.showsHorizontalScrollIndicator = NO;
        _filterCollectionView.delegate = self;
        _filterCollectionView.dataSource = self;
        [_filterCollectionView registerClass:[CJTextCell class] forCellWithReuseIdentifier:[CJTextCell reuseIdentifier]];
    }
    return _filterCollectionView;
}

- (UICollectionView *)beautyCollectionView{
    if (!_beautyCollectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _beautyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _beautyCollectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _beautyCollectionView.showsHorizontalScrollIndicator = NO;
        _beautyCollectionView.delegate = self;
        _beautyCollectionView.dataSource = self;
        [_beautyCollectionView registerClass:[CJTextCell class] forCellWithReuseIdentifier:[CJTextCell reuseIdentifier]];
    }
    return _beautyCollectionView;
}

- (UISlider *)beautySlider{
    if(!_beautySlider){
        _beautySlider = [[UISlider alloc] init];
        _beautySlider.minimumValue = 0;
        _beautySlider.maximumValue = 10;
        [_beautySlider setMinimumTrackTintColor:[UIColor colorWithHex:0x0accac]];
        [_beautySlider setMaximumTrackTintColor:[UIColor whiteColor]];
        [_beautySlider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _beautySlider;
}

- (UILabel *)beautyLabel{
    if(!_beautyLabel){
        _beautyLabel = [[UILabel alloc] init];
        _beautyLabel.backgroundColor = [UIColor whiteColor];
        _beautyLabel.textAlignment = NSTextAlignmentCenter;
        _beautyLabel.text = @"0";
        [_beautyLabel setTextColor:[UIColor colorWithHex:0x0accac]];
    }
    return _beautyLabel;
}

- (UISlider *)filterSlider{
    if(!_filterSlider){
        _filterSlider = [[UISlider alloc] init];
        _filterSlider.minimumValue = 0;
        _filterSlider.maximumValue = 10;
        [_filterSlider setMinimumTrackTintColor:UIColorFromRGB(0x0ACCAC)];
        [_filterSlider setMaximumTrackTintColor:[UIColor whiteColor]];
        [_filterSlider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _filterSlider;
}

- (UILabel *)filterLabel
{
    if(!_filterLabel){
        _filterLabel = [[UILabel alloc] init];
        _filterLabel.backgroundColor = [UIColor whiteColor];
        _filterLabel.textAlignment = NSTextAlignmentCenter;
        _filterLabel.text = @"0";
        [_filterLabel setTextColor:UIColorFromRGB(0x0ACCAC)];
    }
    return _filterLabel;
}

- (NSIndexPath *)selectFunctionIndexPath{
    if(!_selectFunctionIndexPath){
        _selectFunctionIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    return _selectFunctionIndexPath;
}

- (NSIndexPath *)selectStyleIndexPath{
    if(!_selectStyleIndexPath){
        _selectStyleIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return _selectStyleIndexPath;
}

- (NSIndexPath *)selectBeautyIndexPath{
    if(!_selectBeautyIndexPath){
        _selectBeautyIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return _selectBeautyIndexPath;
}

- (NSIndexPath *)selectFilterIndexPath{
    if(!_selectFilterIndexPath){
        _selectFilterIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return _selectFilterIndexPath;
}

- (NSMutableDictionary *)cellCacheForWidth
{
    if(!_cellCacheForWidth){
        _cellCacheForWidth = [NSMutableDictionary dictionary];
    }
    return _cellCacheForWidth;
}

- (void)resetValues
{
    self.beautySlider.hidden = NO;
    self.beautyLabel.hidden = NO;
    self.filterSlider.hidden = YES;
    self.filterLabel.hidden = YES;
    self.beautyCollectionView.hidden = NO;
    self.styleCollectionView.hidden = YES;
    self.filterCollectionView.hidden = YES;
    self.functionCollectionView.hidden = NO;
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.functionCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self collectionView:_functionCollectionView didSelectItemAtIndexPath:indexPath];
    
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.filterCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self collectionView:_filterCollectionView didSelectItemAtIndexPath:indexPath];
    
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.styleCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self collectionView:_styleCollectionView didSelectItemAtIndexPath:indexPath];
    
    [self.beautyCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self collectionView:_beautyCollectionView didSelectItemAtIndexPath:indexPath];
    
    [self.beautyValueMap removeAllObjects];
    [self.beautyValueMap setObject:@(6.3) forKey:@(0)]; //美颜默认值
    [self.beautyValueMap setObject:@(2.7) forKey:@(1)]; //美白默认值
    [self.beautyValueMap setObject:@(2.7) forKey:@(2)]; //红润默认值
    
    _whiteLevel = 2.7;
    _beautyLevel = 6.3;
    _ruddyLevel = 2.7;
    self.beautySlider.value = 6.3;
    self.filterSlider.value = 3;
    [self onValueChanged:self.beautySlider];
    [self onValueChanged:self.filterSlider];
}

- (void)trigglerValues{
    [self onValueChanged:self.beautySlider];
    [self onValueChanged:self.filterSlider];
}
@end
