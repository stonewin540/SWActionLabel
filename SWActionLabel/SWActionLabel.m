//
//  SWActionLabel.m
//  SWActionLabelDemo
//
//  Created by stone win on 6/18/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "SWActionLabel.h"

@interface SWActionLabel ()

@property (nonatomic, assign) CGRect actionFrame;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation SWActionLabel

#pragma mark - Helper

- (void)adjustActionFrame {
    CGRect actionFrame;
    if (self.actionIdentifier)
    {
        actionFrame = self.actionFrame;
        // expend tap region
        actionFrame.size.height = CGRectGetHeight(self.bounds);
        {// set the smallest width between bounds and actionWidth
            CGFloat resetWidth = CGRectGetWidth(self.bounds) - actionFrame.origin.x;
            actionFrame.size.width = MIN(actionFrame.size.width, resetWidth);
        }
        actionFrame.origin.y = (CGRectGetHeight(self.bounds) - actionFrame.size.height) / 2;
    }
    else
    {
        actionFrame = CGRectInfinite;
    }
    self.actionFrame = actionFrame;
}

/**
 @return CGRectInfinite if does not contains actionText
 */
- (CGRect)frameOfActionText:(NSString *)actionText {
    NSString *string = self.text;
    if (nil == string)
    {
        string = self.attributedText.string;
    }
    UIFont *font = self.font;
    __block CGRect actionFrame = CGRectInfinite;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", actionText];
    if ([predicate evaluateWithObject:string])
    {
        NSRange actionRange = [string rangeOfString:actionText];
        NSString *preactionText = [string substringToIndex:actionRange.location];
        
        NSDictionary *attributes = @{NSFontAttributeName: font};
        CGFloat minx = 0;
        {
            CGSize wholeTextSize = [string sizeWithAttributes:attributes];
            
            switch (self.textAlignment) {
                case NSTextAlignmentCenter:
                    minx = (CGRectGetWidth(self.bounds) - wholeTextSize.width) / 2;
                    break;
                case NSTextAlignmentRight:
                    minx = CGRectGetWidth(self.bounds) - wholeTextSize.width;
                    break;
                default:
                    break;
            }
        }
        
        // reset action frame
        actionFrame = CGRectZero;
        actionFrame.origin.x = minx + [preactionText sizeWithAttributes:attributes].width;
        actionFrame.size.height = ceilf([actionText sizeWithAttributes:attributes].height);
        [string enumerateSubstringsInRange:actionRange options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            actionFrame.size.width += [substring sizeWithAttributes:attributes].width;
        }];
    }
    
    return actionFrame;
}

#pragma mark - Property

- (void)setActionIdentifier:(NSString *)actionText {
    if ([self.actionIdentifier isEqualToString:actionText])
    {
        return;
    }
    _actionIdentifier = [actionText copy];
    
    self.actionFrame = [self frameOfActionText:self.actionIdentifier];
    if (CGRectEqualToRect(self.actionFrame, CGRectInfinite))
    {
        return;
    }
    
    [self adjustActionFrame];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    [super setNumberOfLines:1];
    NSAssert((1 == numberOfLines), @"support single line only!!");
}

#pragma mark - Action

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (self.actionBlock)
    {
        __weak __typeof (self) wself = self;
        self.actionBlock(wself);
    }
}

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
        
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:_tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self adjustActionFrame];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.tap == gestureRecognizer)
    {
        CGPoint point = [gestureRecognizer locationInView:self];
        if (!CGRectEqualToRect(self.actionFrame, CGRectInfinite))
        {
            if (CGRectContainsPoint(self.actionFrame, point))
            {
                return YES;
            }
        }
        return NO;
    }
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
