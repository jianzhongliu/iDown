//
//  iDownManager.h
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iDownloader.h"

@interface iDownManager : NSObject

+ (iDownManager *) shared;
- (iDownloader *) addDownloadTaskWithUrlString : (NSString *) url andKey :(NSString *) key;

- (void) startDownloadWithKey : (NSString *) key;
- (void) allStart;

@end
