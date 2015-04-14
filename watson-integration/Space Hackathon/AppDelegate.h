//
//  AppDelegate.h
//  Space Hackathon
//
//  Created by Patrick Chamelo on 12/04/15.
//  Copyright (c) 2015 Patrick Chamelo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) IBOutlet NSTextView *questionTextView;
@property (nonatomic, strong) IBOutlet NSTextView *answerTextView;


- (IBAction)userDidClickRecord:(NSButton *)sender;
- (IBAction)userDidClickPlaySound:(NSButton *)sender;

@end

