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
    NSString *_key;
    
    NSURL *_url;
    NSURLRequest *_req;
    NSURLConnection *_connection;
    
    NSMutableData *_data;
    long long totalLength, currentLength;
    
    NSTimeInterval currentTime, startTime;
    double currentDownloadSpeed;
}

@synthesize delegate = _delegate;

- (id) initWithUrl:(NSURL *)url andKey:(NSString *)key
{
    self = [super init];
    if (self)
    {
        _key = key;
        _url = url;
        
        _req = [[NSURLRequest alloc] initWithURL:_url];
        _connection = [[NSURLConnection alloc] initWithRequest:_req delegate:self];
    }
    
    return self;
}

- (void) startDownload
{
    [_connection start];
}

- (void) pauseDownload
{
    
}

- (void) endDownload
{
    
}

#pragma mark - network

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection to [%@] failed, error : %@", [_url absoluteString], error);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
    currentLength += [data length];
    currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    
    if (_delegate)
    {
        [_delegate didChangeDownloadProgress:currentLength / totalLength withKey:_key];
        
        double _speed = (double)currentLength / 1024.0 / (currentTime - startTime);
        if (abs(_speed - currentDownloadSpeed) > 0.1)
        {
            [_delegate didChangeDownloadSpeedTo:_speed withKey:_key];
            currentDownloadSpeed = _speed;
        }
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
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_delegate)
    {
        [_delegate didFinishDownloadData:_data withKey:_key];
    }
}

@end
