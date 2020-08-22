//
//  KLEmptyView.m
//  KLSocial
//
//  Created by 播呗网络 on 2019/7/9.
//  Copyright © 2019 播呗网络. All rights reserved.
//

#import "KLEmptyView.h"

#define kSubViewMargin 8.f ///<每个子控件之间的间距
#define kTitleLabFont [UIFont systemFontOfSize:12.f]    ///<描述字体
#define kDetailLabFont [UIFont systemFontOfSize:12.f]   ///<详细描述字体
#define kActionBtnFont  [UIFont systemFontOfSize:14.f]  ///<按钮字体大小
#define kActionBtnHeight 40.f   ///<按钮高度
#define kActionBtnWidth 128.f   ///<按钮宽度
#define kBackgroundColor [UIColor colorWithRed:130/255.0 green:58/255.0 blue:255/255.0 alpha:1.0]    ///<背景色
#define kTextColor [UIColor colorWithRed:159/255.0 green:161/255.0 blue:169/255.0 alpha:1.0]///<灰色
#define kActionBtnHorizontalMargin 30.f //水平方向内边距


@interface KLEmptyView ()

@property (nonatomic, strong) UIImageView * promptImageView;
@property (nonatomic, strong) UILabel     * titleLabel;
@property (nonatomic, strong) UILabel     * detailLabel;
@property (nonatomic, strong) UIButton    * actionButton;
@property (nonatomic, strong) UIView      * customV;

@end

@implementation KLEmptyView
{
    CGFloat contentMaxWidth; //最大宽度
    CGFloat contentWidth;    //内容物宽度
    CGFloat contentHeight;   //内容物高度
    CGFloat subViweMargin;   //间距
}

- (void)initialize{
    self.actionBtnHeight = 40.f;
    self.actionBtnWidth = 120.f;
    self.actionBtnHorizontalMargin = 30.f;
}

- (void)prepare{
    [super prepare];
    
    self.autoShowEmptyView = YES; //默认自动显隐
    self.contentViewY = 1000;     //默认值,用来判断是否设置过content的Y值
}

- (void)setupSubviews{
    [super setupSubviews];
    
    contentMaxWidth = self.emptyViewIsCompleteCoverSuperView ? CGRectGetWidth(self.frame) : CGRectGetWidth(self.frame) - 30.f;
    contentWidth = 0;//内容物宽度
    contentHeight = 0;//内容物高度
    subViweMargin = self.subViewsMargin ? self.subViewsMargin : kSubViewMargin;
    
        //占位图片
    if(self.image){
        [self setupPromptImageView:self.image];
    } else {
        if (_promptImageView) {
            [self.promptImageView removeFromSuperview];
            self.promptImageView = nil;
        }
    }
    
        //标题
    if (self.titleStr.length) {
        [self setupTitleLabel:self.titleStr];
    }else{
        if (_titleLabel) {
            [self.titleLabel removeFromSuperview];
            self.titleLabel = nil;
        }
    }
    
        //详细描述
    if (self.detailStr.length) {
        [self setupDetailLabel:self.detailStr];
    }else{
        if (_detailLabel) {
            [self.detailLabel removeFromSuperview];
            self.detailLabel = nil;
        }
    }
    
    //按钮
    if (self.btnTitleStr.length) {
        [self setupActionBtn:self.btnTitleStr btnClickBlock:self.btnActionBlock];
//        if (self.btnActionBlock) {
        
//        }else{
//            if (_actionButton) {
//                [self.actionButton removeFromSuperview];
//                self.actionButton = nil;
//            }
//        }
    }else{
        if (_actionButton) {
            [self.actionButton removeFromSuperview];
            self.actionButton = nil;
        }
    }
    
    //自定义view
    if (self.customView) {
        contentWidth = CGRectGetWidth(self.customView.frame);
        contentHeight = CGRectGetMaxY(self.customView.frame);
    }
    
    ///设置frame
    [self setSubViewFrame];
}

- (void)setSubViewFrame{
    
        //emptyView初始宽高
    CGFloat originEmptyWidth = CGRectGetWidth(self.frame);
    CGFloat originEmptyHeight = CGRectGetHeight(self.frame);
    
    CGFloat emptyViewCenterX = originEmptyWidth * 0.5f;
    CGFloat emptyViewCenterY = originEmptyHeight * 0.5f;
    
    CGRect frame = self.frame;
        //不是完全覆盖父视图时，重新设置self的frame（大小为content的大小）
    if (!self.emptyViewIsCompleteCoverSuperView) {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, contentWidth, contentHeight);
    }
    self.center = CGPointMake(emptyViewCenterX, emptyViewCenterY);
    
        //设置contentView
    CGRect contentViewFrame = self.contentView.frame;
    self.contentView.frame = CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y, contentWidth, contentHeight);
    if (self.emptyViewIsCompleteCoverSuperView) {
        self.contentView.center = CGPointMake(emptyViewCenterX, emptyViewCenterY);
    } else {
        self.contentView.center = CGPointMake(contentWidth*0.5, contentHeight*0.5);
    }
    
        //子控件的centerX设置
    CGFloat centerX = CGRectGetWidth(self.contentView.frame) * 0.5f;
    if (self.customView) {
        CGPoint customViewCenter = self.customView.center;
        self.customView.center = CGPointMake(centerX, customViewCenter.y);
    }else{
        CGPoint promptImageViewCenter = _promptImageView.center;
        CGPoint titleLabel = _titleLabel.center;
        CGPoint detailLabel = _detailLabel.center;
        CGPoint actionButton = _actionButton.center;
        
        _promptImageView.center = CGPointMake(centerX, promptImageViewCenter.y);
        _titleLabel.center = CGPointMake(centerX, titleLabel.y);
        _detailLabel.center = CGPointMake(centerX, detailLabel.y);
        _actionButton.center = CGPointMake(centerX, actionButton.y);
    }
    
    if (self.contentViewOffset) { //有无设置偏移
        CGPoint center = self.center;
        self.center = CGPointMake(center.x, center.y + self.contentViewOffset);
        
    } else if (self.contentViewY < 1000) { //有无设置Y坐标值
        self.frame = CGRectMake(frame.origin.x, self.contentViewY, frame.size.width, frame.size.height);
    }
    
        //是否忽略scrollView的contentInset
    if (self.ignoreContentInset && [self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        CGPoint center = self.center;
        self.center = CGPointMake(center.x - scrollView.contentInset.left,center.y - scrollView.contentInset.top);
    }
}

#pragma mark - ------------------ Setup View ------------------
- (void)setupPromptImageView:(UIImage *)img{
    
    self.promptImageView.image = img;
    
    CGFloat imgViewWidth = img.size.width;
    CGFloat imgViewHeight = img.size.height;
    
    if (self.imageSize.width && self.imageSize.height) {//设置了宽高大小
        if (imgViewWidth > imgViewHeight) {//以宽为基准，按比例缩放高度
            imgViewHeight = (imgViewHeight / imgViewWidth) * self.imageSize.width;
            imgViewWidth = self.imageSize.width;
            
        }else{//以高为基准，按比例缩放宽度
            imgViewWidth = (imgViewWidth / imgViewHeight) * self.imageSize.height;
            imgViewHeight = self.imageSize.height;
        }
    }
    self.promptImageView.frame = CGRectMake(0, 0, imgViewWidth, imgViewHeight);
    
    contentWidth = CGRectGetWidth(self.promptImageView.frame);
    contentHeight = CGRectGetMaxY(self.promptImageView.frame);
}

- (void)setupTitleLabel:(NSString *)titleStr{
    
    UIFont *font = self.titleLabFont.pointSize ? self.titleLabFont : kTitleLabFont;
    CGFloat fontSize = font.pointSize;
    UIColor *textColor = self.titleLabTextColor ? self.titleLabTextColor : kTextColor;
    CGFloat width = [self returnTextWidth:titleStr size:CGSizeMake(contentMaxWidth, fontSize) font:font].width;
    
    self.titleLabel.frame = CGRectMake(0, contentHeight + subViweMargin, width, fontSize);
    self.titleLabel.font = font;
    self.titleLabel.text = titleStr;
    self.titleLabel.textColor = textColor;
    
    contentWidth = width > contentWidth ? width : contentWidth;
    contentHeight = CGRectGetMaxY(self.titleLabel.frame);
}

- (void)setupDetailLabel:(NSString *)detailStr{
    
    UIColor *textColor = self.detailLabTextColor ? self.detailLabTextColor : kTextColor;
    UIFont *font = self.detailLabFont.pointSize ? self.detailLabFont : kDetailLabFont;
    CGFloat fontSize = font.pointSize;
    
    CGFloat maxHeight = self.detailLabMaxLines ? self.detailLabMaxLines * (fontSize + 5) : 2 * (fontSize + 5);//如果没有设置最大行数，默认设置为2行的高度
    
    CGSize size = [self returnTextWidth:detailStr size:CGSizeMake(contentMaxWidth, maxHeight) font:font];//计算得出label大小
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    self.detailLabel.font = font;
    self.detailLabel.frame = CGRectMake(0, contentHeight + subViweMargin, width, height);
    self.detailLabel.text = detailStr;
    self.detailLabel.textColor = textColor;
    
    contentWidth = width > contentWidth ? width : contentWidth;
    contentHeight = CGRectGetMaxY(self.detailLabel.frame);
}

- (void)setupActionBtn:(NSString *)btnTitle btnClickBlock:(KLTapActionBlock)btnClickBlock{

    UIFont *font = self.actionBtnFont.pointSize ? self.actionBtnFont : kActionBtnFont;
    CGFloat fontSize = font.pointSize;
    UIColor *titleColor = self.actionBtnTitleColor ?: kTextColor;
    UIColor *backGColor = self.actionBtnBackGroundColor ?: [UIColor whiteColor];
    UIColor *borderColor = self.actionBtnBorderColor ?: [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.f];
    CGFloat borderWidth = self.actionBtnBorderWidth ?: 0;
    CGFloat cornerRadius = self.actionBtnCornerRadius ?: 0;
    CGFloat width = self.actionBtnWidth;
    CGFloat horiMargin = self.actionBtnHorizontalMargin;
    CGFloat height = self.actionBtnHeight;
    CGSize textSize = [self returnTextWidth:btnTitle size:CGSizeMake(contentMaxWidth, fontSize) font:font];//计算得出title文字内容大小
    if (height < textSize.height) {
        height = textSize.height + 4.f;
    }

    //按钮的宽
    CGFloat btnWidth = textSize.width;
    if (width) {
        btnWidth = width;
    } else if (horiMargin) {
        btnWidth = textSize.width + horiMargin * 2.f;
    }

    //按钮的高
    CGFloat btnHeight = height;
    btnWidth = btnWidth > contentMaxWidth ? contentMaxWidth : btnWidth;

    self.actionButton.frame = CGRectMake(0, contentHeight + subViweMargin, btnWidth, btnHeight);
    [self.actionButton setTitle:btnTitle forState:UIControlStateNormal];
    self.actionButton.titleLabel.font = font;
    self.actionButton.backgroundColor = backGColor;
    [self.actionButton setTitleColor:titleColor forState:UIControlStateNormal];
    self.actionButton.layer.borderColor = borderColor.CGColor;
    self.actionButton.layer.borderWidth = borderWidth;
    self.actionButton.layer.cornerRadius = cornerRadius;

    [self.actionButton addTarget:self action:@selector(actionBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    contentWidth = btnWidth > contentWidth ? btnWidth : contentWidth;
    contentHeight = CGRectGetMaxY(self.actionButton.frame);
}
#pragma mark - ------------------ Properties Set ------------------

- (void)setEmptyViewIsCompleteCoverSuperView:(BOOL)emptyViewIsCompleteCoverSuperView{
    _emptyViewIsCompleteCoverSuperView = emptyViewIsCompleteCoverSuperView;
    if (emptyViewIsCompleteCoverSuperView) {
        if (!self.backgroundColor || [self.backgroundColor isEqual:[UIColor clearColor]]) {
            self.backgroundColor = kBackgroundColor;
        }
        [self setNeedsLayout];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark 内容物背景视图 相关
- (void)setSubViewsMargin:(CGFloat)subViewsMargin{
    if (_subViewsMargin != subViewsMargin) {
        _subViewsMargin = subViewsMargin;
        
        if (_promptImageView || _titleLabel || _detailLabel || _actionButton || self.customView) {//此判断的意思只是确定self是否已加载完毕
            [self setupSubviews];
        }
    }
}
- (void)setContentViewOffset:(CGFloat)contentViewOffset{
    if (_contentViewOffset != contentViewOffset) {
        _contentViewOffset = contentViewOffset;
        
        if (_promptImageView || _titleLabel || _detailLabel || _actionButton || self.customView) {
            CGPoint center = self.center;
            self.center = CGPointMake(center.x, center.y + self.contentViewOffset);
        }
    }
}
- (void)setContentViewY:(CGFloat)contentViewY{
    if (_contentViewY != contentViewY) {
        _contentViewY = contentViewY;
        
        if (_promptImageView || _titleLabel || _detailLabel || _actionButton || self.customView) {
            CGRect frame = self.frame;
            self.frame = CGRectMake(frame.origin.x, self.contentViewY, frame.size.width, frame.size.height);
        }
    }
}

#pragma mark 提示图Image 相关
- (void)setImageSize:(CGSize)imageSize{
    if (_imageSize.width != imageSize.width || _imageSize.height != imageSize.height) {
        _imageSize = imageSize;
        
        if (_promptImageView) {
            [self setupSubviews];
        }
    }
}

#pragma mark 描述Label 相关
- (void)setTitleLabFont:(UIFont *)titleLabFont{
    if (_titleLabFont != titleLabFont) {
        _titleLabFont = titleLabFont;
        
        if (_titleLabel) {
            [self setupSubviews];
        }
    }
    
}
- (void)setTitleLabTextColor:(UIColor *)titleLabTextColor{
    if (_titleLabTextColor != titleLabTextColor) {
        _titleLabTextColor = titleLabTextColor;
        
        if (_titleLabel) {
            _titleLabel.textColor = titleLabTextColor;
        }
    }
}

#pragma mark 详细描述Label 相关
- (void)setDetailLabFont:(UIFont *)detailLabFont{
    if (_detailLabFont != detailLabFont) {
        _detailLabFont = detailLabFont;
        
        if (_detailLabel) {
            [self setupSubviews];
        }
    }
}
- (void)setDetailLabMaxLines:(NSInteger)detailLabMaxLines{
    if (_detailLabMaxLines != detailLabMaxLines) {
        _detailLabMaxLines = detailLabMaxLines;
        
        if (_detailLabel) {
            [self setupSubviews];
        }
    }
}
- (void)setDetailLabTextColor:(UIColor *)detailLabTextColor{
    if (_detailLabTextColor != detailLabTextColor) {
        _detailLabTextColor = detailLabTextColor;
        
        if (_detailLabel) {
            _detailLabel.textColor = detailLabTextColor;
        }
    }
}

#pragma mark Button 相关
    //////////大小位置相关-需要重新布局
- (void)setActionBtnFont:(UIFont *)actionBtnFont{
    if (_actionBtnFont != actionBtnFont) {
        _actionBtnFont = actionBtnFont;
        
        if (_actionButton) {
            [self setupSubviews];
        }
    }
}
- (void)setActionBtnHeight:(CGFloat)actionBtnHeight{
    if (_actionBtnHeight != actionBtnHeight) {
        _actionBtnHeight = actionBtnHeight;
        
        if (_actionButton) {
            [self setupSubviews];
        }
    }
}
- (void)setActionBtnWidth:(CGFloat)actionBtnWidth{
    if (_actionBtnWidth != actionBtnWidth) {
        _actionBtnWidth = actionBtnWidth;
        
        if (_actionButton) {
            [self setupSubviews];
        }
    }
}
- (void)setActionBtnHorizontalMargin:(CGFloat)actionBtnHorizontalMargin{
    if (_actionBtnHorizontalMargin != actionBtnHorizontalMargin) {
        _actionBtnHorizontalMargin = actionBtnHorizontalMargin;
        
        if (_actionButton) {
            [self setupSubviews];
        }
    }
}
    //////////其他相关-直接赋值
- (void)setActionBtnCornerRadius:(CGFloat)actionBtnCornerRadius{
    if (_actionBtnCornerRadius != actionBtnCornerRadius) {
        _actionBtnCornerRadius = actionBtnCornerRadius;
        
        if (_actionButton) {
            _actionButton.layer.cornerRadius = actionBtnCornerRadius;
        }
    }
}
- (void)setActionBtnBorderWidth:(CGFloat)actionBtnBorderWidth{
    if (actionBtnBorderWidth != _actionBtnBorderWidth) {
        _actionBtnBorderWidth = actionBtnBorderWidth;
        
        if (_actionButton) {
            _actionButton.layer.borderWidth = actionBtnBorderWidth;
        }
    }
}
- (void)setActionBtnBorderColor:(UIColor *)actionBtnBorderColor{
    if (_actionBtnBorderColor != actionBtnBorderColor) {
        _actionBtnBorderColor = actionBtnBorderColor;
        
        if (_actionButton) {
            _actionButton.layer.borderColor = actionBtnBorderColor.CGColor;
        }
    }
}
- (void)setActionBtnTitleColor:(UIColor *)actionBtnTitleColor{
    if (_actionBtnTitleColor != actionBtnTitleColor) {
        _actionBtnTitleColor = actionBtnTitleColor;
        
        if (_actionButton) {
            [_actionButton setTitleColor:actionBtnTitleColor forState:UIControlStateNormal];
        }
    }
}
- (void)setActionBtnBackGroundColor:(UIColor *)actionBtnBackGroundColor{
    if (actionBtnBackGroundColor != _actionBtnBackGroundColor) {
        _actionBtnBackGroundColor = actionBtnBackGroundColor;
        
        if (_actionButton) {
            [_actionButton setBackgroundColor:actionBtnBackGroundColor];
        }
    }
}


#pragma mark - ------------------ Event Method ------------------
- (void)actionBtnClick:(UIButton *)sender{
    if (self.btnActionBlock) {
        self.btnActionBlock();
    }
}

#pragma mark - ------------------ Help Method ------------------
- (CGSize)returnTextWidth:(NSString *)text size:(CGSize)size font:(UIFont *)font{
    CGSize textSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    return textSize;
}

#pragma mark - ------------------ 懒加载 ------------------
- (UIImageView *)promptImageView{
    if (!_promptImageView) {
        _promptImageView = [[UIImageView alloc] init];
        _promptImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_promptImageView];
    }
    return _promptImageView;
}
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}
- (UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.numberOfLines = 0;
        [self.contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}
- (UIButton *)actionButton{
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        _actionButton.layer.masksToBounds = YES;
        [self.contentView addSubview:_actionButton];
    }
    return _actionButton;
}

@end
