//
//  iDownloader.m
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownloader.h"

@interface iDownloader () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@end

@implementation iDownloader
{
    NSURL *_url;
    NSURLRequest *_req;
    NSURLConnection *_connection;
    
    NSMutableData *_data;
    long long totalLength, currentLength;
    
    NSTimeInterval currentTime, startTime;
    double currentDownloadSpeed;
}

@synthesize delegate = _delegate;
@synthesize key = _key;

- (id) initWithUrl:(NSURL *)url andKey:(NSString *)key
{
    self = [super init];
    if (self)
    {
        _key = key;
        _url = url;
        
        _req = [[NSURLRequest alloc] initWithURL:_url];
        _connection = [[NSURLConnection alloc] initWithRequest:_req delegate:self startImmediately:NO];
    }
    
    return self;
}

- (bool) startDownload
{
    [_connection start];
    NSLog(@"%s-[%@] connection started", __FUNCTION__, _key);
}

- (bool) pauseDownload
{
    [_connection cancel];
    if (_delegate)
    {
        [_delegate didPausedDownload];
    }
    NSLog(@"%s-[%@] is canceled", __FUNCTION__, _key);
}

- (bool) endDownload
{
    return NO;
}

#pragma mark - network

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (_delegate)
    {
        [_delegate didFailedDownloadFile];
    }
    NSLog(@"%s-Connection to [%@] failed, error : %@", __FUNCTION__, [_url absoluteString], error);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
    currentLength += [data length];
    currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    
    if (_delegate)
    {
        [_delegate didFinishDownloadDataSize: (double) currentLength / 1024.0f];
        [_delegate didChangeDownloadProgress: (double) currentLength / (double) totalLength withKey:_key];
        
        double _speed = (double)currentLength / 1024.0 / (currentTime - startTime);
        if (abs(_speed - currentDownloadSpeed) > 0.1)
        {
            [_delegate didChangeDownloadSpeedTo:_speed withKey:_key];
            currentDownloadSpeed = _speed;
        }
        NSLog(@"%s-[%@] received data [%.2fk], current speed [%.2fk/s]", __FUNCTION__, _key, (double) [data length] / 1024.0, _speed);
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _data = [[NSMutableData alloc] init];
    totalLength = [response expectedContentLength];
    currentLength = 0;
    startTime = [NSDate timeIntervalSinceReferenceDate];
    currentDownloadSpeed = 0;
    if (_delegate)
    {
        [_delegate didChangeDownloadProgress:0 withKey:_key];
        [_delegate didChangeDownloadSpeedTo:0 withKey:_key];
        [_delegate didGetDownloadExpectSize: (double) totalLength / 1024.0];
        NSLog(@"%s-[%@] get expected size [%.2fk], begin download", __FUNCTION__, _key, (double) totalLength / 1024.0f);
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    currentTime = [NSDate timeIntervalSinceReferenceDate];
    if (_delegate)
    {
        [_delegate didFinishDownloadDataSize: (double) totalLength / 1024.0f];
        [_delegate didChangeDownloadProgress:1 withKey:_key];
        [_delegate didFinishDownloadData:_data withKey:_key];
        NSLog(@"%s-[%@] finished download, size [%.2fk], cost time [%.2fs], average speed [%.2fk/s]",
              __FUNCTION__, _key, (double) totalLength / 1024.0f, currentTime - startTime, currentDownloadSpeed);
    }
}

@end
