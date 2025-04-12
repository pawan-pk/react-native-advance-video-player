#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "AdvanceVideoPlayer-Swift.h"

#import "RCTBridge.h"
#import "RCTConvert+MediaTrack.h"

@interface AdvanceVideoPlayerViewManager : RCTViewManager
@end

@implementation AdvanceVideoPlayerViewManager

RCT_EXPORT_MODULE(AdvanceVideoPlayerView)

- (UIView *)view
{
  return [[AdvanceVideoPlayer alloc] init];
}

- (void)setAudioTrack:(UIView *)view track:(MediaTrack *)track {
  if ([view isKindOfClass:[AdvanceVideoPlayer class]]) {
      AdvanceVideoPlayer *playerView = (AdvanceVideoPlayer *)view;
      [playerView setAudioTrackWithType:track.type value:track.value];
  }
}

- (void)setTextTrack:(UIView *)view track:(MediaTrack *)track {
    if ([view isKindOfClass:[AdvanceVideoPlayer class]]) {
        AdvanceVideoPlayer *playerView = (AdvanceVideoPlayer *)view;
        [playerView setTextTrackWithType:track.type value:track.value];
    }
}

RCT_EXPORT_VIEW_PROPERTY(onLoad, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onEnd, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onBuffer, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onProgress, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(url, NSString)
RCT_EXPORT_VIEW_PROPERTY(rate, double)
RCT_EXPORT_VIEW_PROPERTY(muted, BOOL)
RCT_EXPORT_VIEW_PROPERTY(volume, double)
RCT_EXPORT_VIEW_PROPERTY(paused, BOOL)
RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString)

RCT_CUSTOM_VIEW_PROPERTY(selectedAudioTrack, NSArray, NSObject)
{
  MediaTrack *track = [RCTConvert MediaTrack:json];
  [self performSelector:@selector(setAudioTrack:track:) withObject:view withObject:track];
}

RCT_CUSTOM_VIEW_PROPERTY(selectedTextTrack, NSArray, NSObject)
{
  MediaTrack *track = [RCTConvert MediaTrack:json];
  [self performSelector:@selector(setTextTrack:track:) withObject:view withObject:track];
}
@end
