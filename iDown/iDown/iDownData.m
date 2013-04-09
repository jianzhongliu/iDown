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
    iDownState _oldState;
    
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

- (NSString *) description
{
    return [NSString stringWithFormat:@"key = %@\ndownloader = {\n%@\n}\nlength = %lld\nstate = %@",
            _key,
            _downloader,
            _storedLength,
            _state];
}

- (id) initWithUrl:(NSString *)urlString
{
    self = [super init];
    if (self)
    {
        _urlString = urlString;
        _key = nil;
        _fileCreated = NO;
        _filePath = nil;
        _fileHandle = nil;
        
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
        _oldState = iDownStateUnknown;
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
    NSLog(@"%s-[%@] received [%d] event, state changes to [%d]",
          __FUNCTION__, _key, event, _state.state);
    [self handleNextState];
}

- (NSDictionary *) exportToDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:_key forKey:@"key"];
    [dic setValue:_urlString forKey:@"url"];
    [dic setValue:[NSNumber numberWithUnsignedLongLong:_storedLength] forKey:@"storedLength"];
    [dic setValue:[NSNumber numberWithInt:(int)_state.state] forKey:@"state"];
    [dic setValue:[_downloader exportToDictionary] forKey:@"downloader"];
    
    return dic;
}

+ (iDownData *) importFromDictionary : (NSDictionary *) dic
{
    iDownData *temp = [[iDownData alloc] initWithUrl:[dic objectForKey:@"url"]];
    temp.key = [dic objectForKey:@"key"];
    temp.state = [[iDownStateMachine alloc] initWithState:[[dic objectForKey:@"state"] intValue]];
    [temp importDownloaderFromDic: dic];
    
//    NSLog(@"%s-[%@] imported from status file:\n%@", __FUNCTION__, temp.key, dic);
    return temp;
}

#pragma mark - privates

- (void) importDownloaderFromDic : (NSDictionary *) dic
{
    _storedLength = [(NSNumber *)[dic objectForKey:@"storedLength"] unsignedLongLongValue];
    _oldState = [(NSNumber *)[dic objectForKey:@"state"] intValue];
    _downloader = [iDownloader importFromDictionary:(NSDictionary *) [dic objectForKey:@"downloader"]];
    _downloader.storageDelegate = self;
}

- (void) handleNextState
{
    if (_state.state == _oldState)
        return;
    
    _oldState = _state.state;
    switch (_state.state) {
        case iDownStateDownloading:
            [self startDownload];
            break;
            
        case iDownStatePaused:
            [self pauseDownload];
            break;
            
        case iDownStateSucceed:
            [self succeedDownload];
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
    _storedLength = 0;
    _filePath = nil;
    _fileCreated = NO;
    _fileHandle = nil;
}

- (void) succeedDownload
{
    [_downloader succeedDownload];
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
    _filePath = [self getFilePathWithName:fileName];
    
    if ([self checkFileValid])//file exists and valid to stored length
    {
        _fileCreated = YES;
        _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
    }
    else if (!_fileCreated)//file not exists
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:_filePath])
        {
            [fileManager removeItemAtPath:_filePath error:nil];
            NSLog(@"%s-File [%@] exists, delete it", __FUNCTION__, _filePath);
        }        
        [fileManager createFileAtPath:_filePath contents:nil attributes:nil];
        NSLog(@"%s-File [%@] created", __FUNCTION__, _filePath);

        _fileCreated = YES;
        _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
        _storedLength = 0;
    }
    else//file exists but not valid
    {
        [self handleEvent:iDownEventFileCheckInvalid];
    }
}

- (void) reportComplete
{
    [_fileHandle closeFile];
    _fileCreated = NO;
    
    NSFileManager * filemanager = [[NSFileManager alloc] init];
    if([filemanager fileExistsAtPath: _filePath])
    {
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:_filePath error:nil];
        NSNumber *theFileSize = [attributes objectForKey:NSFileSize];
        NSLog(@"%s-checkfile [%@], [%.2fk]", __FUNCTION__, _filePath, (double) [theFileSize intValue]);
        
        [self handleEvent:iDownEventFinishedDownload];
    }
}

- (bool) checkFileValid
{    
    NSFileManager * filemanager = [[NSFileManager alloc] init];
    NSDictionary * attributes = [filemanager attributesOfItemAtPath:_filePath error:nil];
    if (!attributes)
        return NO;
    
    NSNumber *theFileSize = [attributes objectForKey:NSFileSize];
    
    if ([theFileSize unsignedLongLongValue] != _storedLength)
    {
        NSLog(@"%s-[%@] is checked invalid, file size = [%lld] but storedLength = [%lld]",
              __FUNCTION__, _filePath, [theFileSize unsignedLongLongValue], _storedLength);
        return NO;
    }
    
    return YES;
}

- (NSString *) getFilePathWithName : (NSString *) name
{
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:name];
}

@end
