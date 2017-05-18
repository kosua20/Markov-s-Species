#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    // To complete your generator please implement the function GeneratePreviewForURL in GeneratePreviewForURL.c
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineHeightMultiple:0.88];
    //[style setAlignment:NSTextAlignmentLeft];
    
    
    NSDictionary *tabsStyle = @{ NSFontAttributeName : [NSFont fontWithName:@"Menlo-Regular" size:25.0],
                             NSForegroundColorAttributeName : [NSColor blackColor], NSParagraphStyleAttributeName:style};
    NSDictionary *corps = @{ NSFontAttributeName : [NSFont fontWithName:@"Menlo-Regular" size:25.0],
                             NSForegroundColorAttributeName : [NSColor blackColor], NSParagraphStyleAttributeName:style, NSBackgroundColorAttributeName:[NSColor colorWithRed:0.8927 green:0.8928 blue:0.8926 alpha:1.0]};
     NSDictionary *small = @{ NSFontAttributeName : [NSFont fontWithName:@"Helvetica-Bold" size:14.0],NSForegroundColorAttributeName : [NSColor grayColor] };
    NSDictionary *bold = @{ NSFontAttributeName : [NSFont fontWithName:@"Helvetica-Bold" size:28.0],NSForegroundColorAttributeName : [NSColor darkGrayColor] };
    NSDictionary *titleAtt = @{ NSFontAttributeName : [NSFont fontWithName:@"Helvetica-Bold" size:32.0],NSForegroundColorAttributeName : [NSColor blackColor]};
    
    NSAttributedString *newline = [[NSAttributedString alloc] initWithString:@"\n"];
    NSAttributedString *tabs = [[NSAttributedString alloc] initWithString:@"\t\t\t" attributes:tabsStyle];
    NSMutableAttributedString *output = [[NSMutableAttributedString alloc] init];
    
    NSString *_content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray *arr = [[_content componentsSeparatedByString:@"\n"] mutableCopy];
    NSArray *dims =  [[arr objectAtIndex:0] componentsSeparatedByString:@","];
    NSInteger height = [dims[0] integerValue];
    NSInteger width = [dims[1] integerValue];
    [arr removeObjectAtIndex:0];
    
    NSMutableArray *arr2 = [NSMutableArray arrayWithCapacity:arr.count];
    for(NSString*  str in arr){
        if(str.length !=0){
            [arr2 addObject:[[NSAttributedString alloc] initWithString:str attributes:corps]];
            //NSLog(@"%i :%@:",str.length,str);
        }
    }
    
    //NSString *remainingContent = [arr2 componentsJoinedByString:@"\n"];
    //NSLog(@"%i",remainingContent.length);
    NSString *title = [(__bridge NSURL *)url lastPathComponent];
    title = [title stringByReplacingOccurrencesOfString:@".grid" withString:@""];
    NSRange res = [title rangeOfString:@"_" options:NSBackwardsSearch];
    title = [NSString stringWithFormat:@"\t\t%@",[title substringToIndex: res.location]];
    
    NSString *startContent = [NSString stringWithFormat:@"\t\tGrid of size %ld x %ld",height,width];
   // NSString *fullContent = [NSString stringWithFormat:@"%@\n\n\n%@", startContent, remainingContent];
    NSAttributedString *headerString = [[NSAttributedString alloc] initWithString:title attributes:titleAtt];
    NSAttributedString *headerString1 = [[NSAttributedString alloc] initWithString:startContent attributes:bold];
    NSAttributedString *headerString2 = [[NSAttributedString alloc] initWithString:@"\t\t(height x width)" attributes:small];
  //  NSAttributedString *contentString = [[NSAttributedString alloc] initWithString:remainingContent attributes:corps];
    [output appendAttributedString:newline];
    [output appendAttributedString:newline];
    [output appendAttributedString:headerString];
    [output appendAttributedString:newline];
    [output appendAttributedString:headerString1];
    [output appendAttributedString:newline];
    [output appendAttributedString:headerString2];
    [output appendAttributedString:newline];
    [output appendAttributedString:newline];
    for(NSAttributedString *astr in arr2){
        [output appendAttributedString:newline];
        [output appendAttributedString:tabs];
        [output appendAttributedString:astr];
    }
    
//[output appendAttributedString:contentString];
    //NSDictionary *dic = @{(__bridge_transfer NSString*)kQLPreviewPropertyHeightKey : @200, (__bridge_transfer NSString*)kQLPreviewPropertyWidthKey : @100};
    
    CFMutableDictionaryRef dict;
    CFNumberRef c_height;
    CFNumberRef c_width;
    int _height = 200;
    int _width = 200;
    dict = CFDictionaryCreateMutable(NULL, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    c_height = CFNumberCreate(NULL, kCFNumberIntType, &_height);
    c_width = CFNumberCreate(NULL, kCFNumberIntType, &_width);
    CFDictionarySetValue(dict, kQLPreviewPropertyHeightKey, c_height);
    CFDictionarySetValue(dict, kQLPreviewPropertyWidthKey, c_width);
    CFRelease(c_height);
    CFRelease(c_width);
    
    
    QLPreviewRequestSetDataRepresentation(preview,(__bridge CFDataRef)[output RTFFromRange:NSMakeRange(0, output.length) documentAttributes:nil],kUTTypeRTF,dict);
    
    
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
