//
//  AppDelegate.m
//  Space Hackathon
//
//  Created by Patrick Chamelo on 12/04/15.
//  Copyright (c) 2015 Patrick Chamelo. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "AppDelegate.h"

NSString *const kErrorMessage = @"Something went wrong, try again";

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation AppDelegate
{
    BOOL _isRecording;
    NSMutableData *_responseData;
    NSString *_answerText;
    NSString *_questionText;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{

}

// ------------------------------------------------------------------------------------------
#pragma mark - Actions
// ------------------------------------------------------------------------------------------

- (IBAction)userDidClickRecord:(NSButton *)sender
{
    if (_isRecording == NO) {
        NSURL *audioFileURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/audioRecording.wav"]];
        
        NSMutableDictionary *recordSettings = [NSMutableDictionary dictionary];
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:16000] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
        
        NSError *error;
        self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:audioFileURL settings:recordSettings error:&error];
        [self.audioRecorder record];
    } else {
        [self.audioPlayer stop];
        [self.audioRecorder stop];
    }
    _isRecording = !_isRecording;
    [self _updateButtonTitle:sender];
}


- (IBAction)userDidClickPlaySound:(NSButton *)sender
{
    NSURL *audioFileURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/audioRecording.wav"]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
    [self.audioPlayer play];
}


- (void)_updateButtonTitle:(NSButton *)button
{
    if (_isRecording) {
        [button setTitle:@"Stop Recording"];
    } else {
        [button setTitle:@"Start Recording"];
    }
}

- (IBAction)userDidClickSendToWatson:(NSButton *)sender
{
    self.questionTextView.string = @"";
    self.answerTextView.string = @"";
    
    NSMutableURLRequest *request = [self _basicURLRequestForPath:@"https://stream.watsonplatform.net/speech-to-text-beta/api/v1/recognize"];
    [request setValue:@"audio/l16; rate=16000; channels=1;" forHTTPHeaderField:@"Content-Type"];
    NSURL *audioFileURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/audioRecording.wav"]];
    NSData *data = [NSData dataWithContentsOfURL:audioFileURL];

    NSString *post = [NSString stringWithFormat:@"%@",data];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[@"Content-Type: audio/l16; rate=16000; channels=1" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         _questionText = [self _questionFromResponseData:data];
         [self.questionTextView setString:_questionText];
         if (_questionText.length > 0 && [_questionText isEqualToString:kErrorMessage] == NO) {
             
             NSMutableURLRequest *request = [self _basicURLRequestForPath:@"https://gateway.watsonplatform.net/question-and-answer-beta/api/v1/question/travel"];
             [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
             NSDictionary *d1 = [NSDictionary dictionaryWithObject:_questionText forKey:@"questionText"];
             NSDictionary *d2 = [NSDictionary dictionaryWithObject:d1 forKey:@"question"];
             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:d2 options:NSJSONWritingPrettyPrinted error:nil];
             [request setHTTPBody:jsonData];
             
             [NSURLConnection sendAsynchronousRequest:request
                                                queue:[NSOperationQueue mainQueue]
                                    completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
             {
                 _answerText = [self _answerResponseData:data];
                 [self.answerTextView setString:_answerText];
             }];
         }
     }];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private Helpers
// ------------------------------------------------------------------------------------------

- (NSMutableURLRequest *)_basicURLRequestForPath:(NSString *)path
{
    NSURL *aUrl = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSData *userCredentialsData = [@"111ed397-aa20-426b-8599-9d75bbedce8b:7rte4flmMBSy" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Encoded = [userCredentialsData base64EncodedStringWithOptions:0];
    [request setValue:[NSString stringWithFormat:@"Basic %@", base64Encoded] forHTTPHeaderField:@"Authorization"];
    return request;
}

- (NSString *)_questionFromResponseData:(NSData *)responseData
{
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    if (error != nil) {
        NSLog(@"Error parsing JSON.");
    }
    else {
        NSLog(@"%@", dictionary);
        NSArray *results = [dictionary objectForKey:@"results"];
        if (results.count > 0) {
            NSArray *transcript = [results[0] objectForKey:@"alternatives"];
            if (transcript.count > 0) {
                NSString *questions = [transcript[0] objectForKey:@"transcript"];
                return questions;
            }
        }
    }
    return kErrorMessage;
}


- (NSString *)_answerResponseData:(NSData *)responseData
{
    NSError *error = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    if (error != nil) {
        NSLog(@"Error parsing JSON.");
    }
    else {
        NSLog(@"%@", array);
        if (array.count > 0) {
            NSDictionary *question = array[0];
            NSArray *answers = [[question objectForKey:@"question"] objectForKey:@"evidencelist"];
            if (answers.count > 0) {
                NSDictionary *bestAnswer = answers[0];
                return [bestAnswer objectForKey:@"text"];
            }
            
            answers = [[question objectForKey:@"question"] objectForKey:@"answers"];
            if (answers.count > 0) {
                NSDictionary *bestAnswer = answers[0];
                return [bestAnswer objectForKey:@"text"];
            }
        }
    }

    return kErrorMessage;
}

@end
