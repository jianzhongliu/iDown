//
//  iDownData.m
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownData.h"
#import "iDownManager.h"

@interface iDownData () <iDownloadStorage>

@end

@implementation iDownData
{
    NSString *_urlString;
    NSFileHandle *_fileHandle;
    NSString *_filePath;
    bool _fileCreated;
    iDownState oldState;
    
    unsigned long long _storedLength;
}

@synthesize key = _key;
@synthesize size = _size;
@synthesize downloader = _downloader;
@synthesize delegate = _delegate;
@synthesize state = _state;

+ (NSString *) getDefaultKey
{
    static int defaultId = 0;
    return [NSString stringWithFormat:@"item %d", defaultId ++];
}

- (id) initWithUrl:(NSString *)urlString
{
    self = [super init];
    if (self)
    {
        _urlString = urlString;
        _key = NULL;
        _fileCreated = NO;
        
        for (int i = [_urlString length]; i > 0; -- i)
        {
            if ([_urlString characterAtIndex: i - 1] == '/')
            {
                _key = [_urlString substringFromIndex:i + 1];
                break;
            }
        }
        
        if (!_key)
        {
            _key = [iDownData getDefaultKey];
        }
        
        _downloader = [[iDownManager shared] addDownloadTaskWithUrlString:_urlString andKey:_key];
        _downloader.storageDelegate = self;
        _state = [[iDownStateMachine alloc] initWithState:iDownStateUnknown];
        oldState = iDownStateUnknown;
    }

    return self;
}

#pragma mark - getter/setter

- (void) setDownloadEventHandler:(id<iDownloaderEvent>)delegate
{
    _downloader.eventDelegate = delegate;
}

- (void) setKey:(NSString *)key
{
    _key = key;
    _downloader.key = _key;
}

#pragma mark - interfaces

- (void) handleEvent:(iDownEvent)event
{
    [_state nextStateWithEvent:event];
    [self handleNextState];
}

- (NSDictionary *) exportToDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:_key forKey:@"key"];
    [dic setValue:_urlString forKey:@"url"];
    [dic setValue:[NSNumber numberWithInt:(int)_state.state] forKey:@"state"];
    [dic setValue:[_downloader exportToDictionary] forKey:@"downloader"];
    
    return dic;
}

+ (iDownData *) importFromDictionary : (NSDictionary *) dic
{
    iDownData *temp = [[iDownData alloc] initWithUrl:[dic objectForKey:@"url"]];
    temp.key = [dic objectForKey:@"key"];
    temp.state = [[iDownStateMachine alloc] initWithState:[[dic objectForKey:@"state"] intValue]];
    [temp importDownloaderFromDic:(NSDictionary *) [dic objectForKey:@"downloader"]];
    
    NSLog(@"%s-[%@] imported from status file:\n%@", __FUNCTION__, temp.key, dic);
    return temp;
}

#pragma mark - privates

- (void) importDownloaderFromDic : (NSDictionary *) dic
{
    _downloader = [iDownloader importFromDictionary:dic];
}

- (void) handleNextState
{
    if (_state.state == oldState)
        return;
    
    oldState = _state.state;
    switch (_state.state) {
        case iDownStateDownloading:
            [self startDownload];
            break;
            
        case iDownStatePaused:
            [self pauseDownload];
            break;
            
        case iDownStateSucceed:
            break;
            
        case iDownStateFailed:
            [self endDownload];
            break;
        
        case iDownStateUnknown:
            [self restartDownload];
            break;
            
        default:
            break;
    }
}

- (void) idle
{
    if (_delegate)
    {
        [_delegate stateChanged];
    }
    
    [_downloader idle];
}

- (void) startDownload
{
    [self idle];
    [_downloader startDownload];
}

- (void) pauseDownload
{
    [self idle];
    [_downloader pauseDownload];
}

- (void) restartDownload
{
    [self idle];
    [_downloader endDownload];
    [_downloader startDownload];
}

- (void) endDownload
{
    [_downloader endDownload];
}

#pragma mark - data storage

- (void) reportData:(NSData *)data
{
    if (!data)
        return;
    
    NSLog(@"%s-[%@] write from [%lld] for [%d] length",
          __FUNCTION__, _filePath, _storedLength, [data length]);
    
    _storedLength += [data length];
    [_fileHandle seekToEndOfFile];
    [_fileHandle writeData:data];
}

- (void) reportFileName:(NSString *)name
{
    NSString *fileName = name;
    if (!fileName)
        fileName = _key;
    
    if (!_fileCreated)
    {
        NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [directoryPaths objectAtIndex:0];
        NSString *filePath = [documentDirectory stringByAppendingPathComponent:fileName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:filePath])
        {
            [fileManager removeItemAtPath:filePath error:nil];
            NSLog(@"%s-File [%@] exists, delete it", __FUNCTION__, filePath);
        }        
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"%s-File [%@] created", __FUNCTION__, filePath);

        _fileCreated = YES;
        _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        _filePath = filePath;
        _storedLength = 0;
    }
}

- (void) reportComplete
{
    [_fileHandle closeFile];
    _fileCreated = NO;
    
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath: _filePath])
    {
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:_filePath error:nil];
        NSNumber *theFileSize = [attributes objectForKey:NSFileSize];
        NSLog(@"%s-checkfile [%@], [%.2fk]", __FUNCTION__, _filePath, (double) [theFileSize intValue]);
    }
}

@end
