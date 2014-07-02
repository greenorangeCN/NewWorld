//
//  ActivityCell.m
//  NewWorld
//
//  Created by Seven on 14-7-1.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ActivityCell.h"

@implementation ActivityCell

-(void)initGR
{
    UILongPressGestureRecognizer *longPressGR = [[ UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGR.minimumPressDuration = 0.7;
    [self addGestureRecognizer:longPressGR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if([self isHighlighted])
    {
        [[self delegate] performSelector:@selector(showMenu:) withObject:self];
    }
}
- (void)delete:(id)sender
{
    [[self delegate]  performSelector:@selector(deleteRow:) withObject:self];
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(delete:))
    {
        return YES;
    }
    else
    {
        return [super canPerformAction:action withSender:sender];
    }
}

@end
