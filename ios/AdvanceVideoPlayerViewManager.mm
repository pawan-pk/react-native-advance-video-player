#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "AdvanceVideoPlayer-Swift.h"

#import "RCTBridge.h"
#import <React/RCTEventEmitter.h>

#import <VLCKit/VLCMediaPlayerTitleDescription.h>
#import <VLCKit/VLCMediaMetaData.h>
#import <VLCKit/VLCMediaPlayer.h>
#import <VLCKit/VLCMedia.h>
#import <VLCKit/VLCTime.h>

@interface AdvanceVideoPlayerViewManager : RCTViewManager <VLCMediaPlayerDelegate, VLCMediaDelegate>

@end

@implementation AdvanceVideoPlayerViewManager {
    AdvanceVideoPlayer * _player;
    BOOL _videoLoaded;
    BOOL _buffering;
//    RCTDirectEventBlock onLoad;
//    RCTDirectEventBlock onEnd;
//    RCTDirectEventBlock onError;
//    RCTDirectEventBlock onBuffer;
//    RCTDirectEventBlock onProgress;
}

RCT_EXPORT_MODULE(AdvanceVideoPlayerView)

- (UIView *)view
{
    _player = [[AdvanceVideoPlayer alloc] init];
    _player.delegate = self;
    _player.mediaDelegate = self;
    return _player;
}
//RCT_CUSTOM_VIEW_PROPERTY

//RCT_EXPORT_VIEW_PROPERTY(onLoad, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onEnd, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onBuffer, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onProgress, RCTDirectEventBlock)

RCT_EXPORT_VIEW_PROPERTY(url, NSString)
RCT_EXPORT_VIEW_PROPERTY(rate, double)
RCT_EXPORT_VIEW_PROPERTY(muted, BOOL)
RCT_EXPORT_VIEW_PROPERTY(volume, double)
RCT_EXPORT_VIEW_PROPERTY(paused, BOOL)
RCT_EXPORT_VIEW_PROPERTY(aspectRatio, NSString)
RCT_EXPORT_VIEW_PROPERTY(audioTrack, int)
RCT_EXPORT_VIEW_PROPERTY(textTrack, int)

@end
