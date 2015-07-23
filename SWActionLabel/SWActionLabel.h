//
//  SWActionLabel.h
//  SWActionLabelDemo
//
//  Created by stone win on 6/18/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWActionLabel;
typedef void(^SWActionLabelBlock)(SWActionLabel *label);

@interface SWActionLabel : UILabel

@property (nonatomic, copy) NSString *actionIdentifier;
@property (nonatomic, copy) SWActionLabelBlock actionBlock;

- (void)setActionBlock:(void(^)(SWActionLabel *label))actionBlock;

@end
