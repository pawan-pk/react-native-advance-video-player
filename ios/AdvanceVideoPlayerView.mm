#import "AdvanceVideoPlayerView.h"

#import <AdvanceVideoPlayer/ComponentDescriptors.h>
#import <AdvanceVideoPlayer/EventEmitters.h>
#import <AdvanceVideoPlayer/Props.h>
#import <AdvanceVideoPlayer/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"
#import "AdvanceVideoPlayer-Swift.h"
#import "RCTConvert+MediaTrack.h"
#import <MobileVLCKit/VLCMediaPlayer.h>

using namespace facebook::react;

@interface AdvanceVideoPlayerView () <RCTAdvanceVideoPlayerViewViewProtocol, VLCMediaPlayerDelegate>

@end

@implementation AdvanceVideoPlayerView {
  AdvanceVideoPlayer * _player;
  NSDictionary * _videoInfo;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<AdvanceVideoPlayerViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const AdvanceVideoPlayerViewProps>();
    _props = defaultProps;
    
    _player = [[AdvanceVideoPlayer alloc] init];
    _player.frame = frame;
    _player.delegate = self;
    self.contentView = _player;
  }

  return self;
}

- (std::shared_ptr<const AdvanceVideoPlayerViewEventEmitter>)getEventEmitter
{
    if (!self->_eventEmitter) {
        return nullptr;
    }

    assert(std::dynamic_pointer_cast<AdvanceVideoPlayerViewEventEmitter const>(self->_eventEmitter));
    return std::static_pointer_cast<AdvanceVideoPlayerViewEventEmitter const>(self->_eventEmitter);
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<AdvanceVideoPlayerViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<AdvanceVideoPlayerViewProps const>(props);

    if (oldViewProps.url != newViewProps.url) {
        NSString * url = [[NSString alloc] initWithUTF8String: newViewProps.url.c_str()];
        _player.url = url;
    }
  
    if (oldViewProps.rate != newViewProps.rate) {
        _player.rate = newViewProps.rate;
    }
  
    if (oldViewProps.muted != newViewProps.muted) {
        _player.muted = newViewProps.muted;
    }
  
    if (oldViewProps.volume != newViewProps.volume) {
        _player.volume = newViewProps.volume;
    }
  
    if (oldViewProps.paused != newViewProps.paused) {
        _player.paused = newViewProps.paused;
    }
  
    if (oldViewProps.resizeMode != newViewProps.resizeMode) {
      NSString * resizeMode = [[NSString alloc] initWithUTF8String: newViewProps.resizeMode.c_str()];
        _player.resizeMode = resizeMode;
    }
    
    if (oldViewProps.selectedAudioTrack.type != newViewProps.selectedAudioTrack.type || oldViewProps.selectedAudioTrack.value != newViewProps.selectedAudioTrack.value) {
      NSString * audioTrackType = [[NSString alloc] initWithUTF8String: newViewProps.selectedAudioTrack.type.c_str()];
      NSString * audioTrackValue = [[NSString alloc] initWithUTF8String: newViewProps.selectedAudioTrack.value.c_str()];
      [_player setAudioTrackWithType:audioTrackType value:audioTrackValue];
    }
  
    if (oldViewProps.selectedTextTrack.type != newViewProps.selectedTextTrack.type || oldViewProps.selectedTextTrack.value != newViewProps.selectedTextTrack.value) {
      NSString * textTrackType = [[NSString alloc] initWithUTF8String: newViewProps.selectedTextTrack.type.c_str()];
      NSString * textTrackValue = [[NSString alloc] initWithUTF8String: newViewProps.selectedTextTrack.value.c_str()];
      [_player setTextTrackWithType:textTrackType value:textTrackValue];
    }

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> AdvanceVideoPlayerViewCls(void)
{
    return AdvanceVideoPlayerView.class;
}

// MARK: - Helper functions
- (NSDictionary *)getVideoInfo:(VLCMediaPlayer *)_player
{
  NSMutableDictionary *info = [NSMutableDictionary new];
  //  info[@"duration"] = _player.media
  int i;
  if (_player.videoSize.width > 0) {
    info[@"videoSize"] =  @{
      @"width":  @(_player.videoSize.width),
      @"height": @(_player.videoSize.height)
    };
  }
  
  if (_player.numberOfAudioTracks > 0) {
    NSMutableArray *tracks = [NSMutableArray new];
    for (i = 0; i < _player.numberOfAudioTracks; i++) {
      if (_player.audioTrackIndexes[i] && _player.audioTrackNames[i]) {
        [tracks addObject:  @{
          @"id": _player.audioTrackIndexes[i],
          @"name":  _player.audioTrackNames[i]
        }];
      }
    }
    info[@"audioTracks"] = tracks;
  }
  
  if (_player.numberOfSubtitlesTracks > 0) {
    NSMutableArray *tracks = [NSMutableArray new];
    for (i = 0; i < _player.numberOfSubtitlesTracks; i++) {
      if (_player.videoSubTitlesIndexes[i] && _player.videoSubTitlesNames[i]) {
        [tracks addObject:  @{
          @"id": _player.videoSubTitlesIndexes[i],
          @"name":  _player.videoSubTitlesNames[i]
        }];
      }
    }
    info[@"textTracks"] = tracks;
  }
  
  return info;
}

// MARK: - VLCMediaPlayerDelegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{
  if ([aNotification.object isKindOfClass:[VLCMediaPlayer class]]) {
    VLCMediaPlayer *_player = (VLCMediaPlayer *)aNotification.object;
    VLCMediaPlayerState state = _player.state;
    const auto eventEmitter = [self getEventEmitter];
    switch (state) {
      case VLCMediaPlayerStateOpening:
        eventEmitter->onLoad(AdvanceVideoPlayerViewEventEmitter::OnLoad{
          .subtitle = "Testing",
          .audioTrack = "0",
          .duration = 2.0,
          .aspectRatio = 1
        });
        break;
      case VLCMediaPlayerStatePaused:
        eventEmitter->onPaused({});
        break;
      case VLCMediaPlayerStateStopped:
        eventEmitter->onStop({});
        break;
      case VLCMediaPlayerStateBuffering:
        if (!_videoInfo && _player.numberOfAudioTracks > 0) {
          _videoInfo = [self getVideoInfo:_player];
          NSLog(@"Video Details:%@",_videoInfo);
          eventEmitter->onLoad(AdvanceVideoPlayerViewEventEmitter::OnLoad{
            .subtitle = "Testing",
            .audioTrack = "0",
            .duration = 2.0,
            .aspectRatio = 1
          });
        }
        eventEmitter->onBuffer(AdvanceVideoPlayerViewEventEmitter::OnBuffer{
          .buffering = true
        });
        break;
      case VLCMediaPlayerStatePlaying:
        eventEmitter->onBuffer(AdvanceVideoPlayerViewEventEmitter::OnBuffer{
          .buffering = false
        });
        break;
      case VLCMediaPlayerStateEnded:
        eventEmitter->onEnd({});
        break;
      case VLCMediaPlayerStateESAdded:
        RCTLog(@"mediaPlayerTimeChanged: %@", aNotification.object);
        break;
      case VLCMediaPlayerStateError:
        NSString *errorString = [NSString stringWithFormat:@"[VLCMediaPlayerStateError]:%d", _player.numberOfAudioTracks];
        eventEmitter->onError(AdvanceVideoPlayerViewEventEmitter::OnError{
          .error = [errorString UTF8String]
        });
        break;
    }
  }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
  RCTLog(@"mediaPlayerTimeChanged: %@", aNotification.object);
  [_player onPlay];
}

- (void)mediaPlayerTitleChanged:(NSNotification *)aNotification
{
  RCTLog(@"mediaPlayerTitleChanged: %@", aNotification);
}

- (void)mediaPlayerChapterChanged:(NSNotification *)aNotification
{
  RCTLog(@"mediaPlayerChapterChanged: %@", aNotification);
}

- (void)mediaPlayerSnapshot:(NSNotification *)aNotification
{
  RCTLog(@"mediaPlayerSnapshot: %@", aNotification);
}

- (void) mediaPlayerLoudnessChanged:(NSNotification *)aNotification
{
  RCTLog(@"mediaPlayerLoudnessChanged: %@", aNotification);
}

- (void) mediaPlayerStartedRecording:(VLCMediaPlayer *)player
{
  RCTLog(@"mediaPlayerStartedRecording");
}

- (void) mediaPlayer:(VLCMediaPlayer *)player recordingStoppedAtPath:(NSString *) path
{
  RCTLog(@"mediaPlayer recordingStoppedAtPath: %@", path);
}

@end
