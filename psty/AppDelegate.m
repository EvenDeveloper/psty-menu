//
//  AppDelegate.m
//  psty
//
//  Created by Even Flatabø on 20/12/2019.
//  Copyright © 2019 EvenDev. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)awakeFromNib {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setTitle:@"psty"];
    [statusItem setHighlightMode:YES];
    [statusItem setTarget:self];
    [statusItem setAction:@selector(makePaste:)];
    
    // Hello Max
    // I'm done
    // Just gotta fix some string escape shit
}

-(void)makePaste:(id)sender {
    NSString *clipboard = [NSPasteboard.generalPasteboard stringForType:NSPasteboardTypeString];
    if (clipboard.length > 0) {
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://psty.io/api"]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[[NSString stringWithFormat:@"lang=plaintext&code=%@", [self URLEncode:clipboard encoding:NSUTF8StringEncoding]] dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"The response is - %@",responseDictionary);
            if(httpResponse.statusCode == 200)
            {
                NSString *pasteLink = [responseDictionary objectForKey:@"paste_link"];
                [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:pasteLink]];
            } else {
                [self->statusItem setTitle:@"psty ERROR"];
            }
        }];
        [dataTask resume];
    }
}

- (NSString *)URLEncode:(NSString *)originalString encoding:(NSStringEncoding)encoding
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault,
        (__bridge CFStringRef)originalString,
        NULL,
        CFSTR(":/?#[]@!$&'()*+,;="),
        CFStringConvertNSStringEncodingToEncoding(encoding));
}

@end
