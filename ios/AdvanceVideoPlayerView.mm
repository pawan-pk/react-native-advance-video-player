#import "AdvanceVideoPlayerView.h"

#import <AdvanceVideoPlayer/ComponentDescriptors.h>
#import <AdvanceVideoPlayer/EventEmitters.h>
#import <AdvanceVideoPlayer/Props.h>
#import <AdvanceVideoPlayer/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"
#import "AdvanceVideoPlayer-Swift.h"
#import "RCTConvert+MediaTrack.h"
#import <MobileVLCKit/VLCMediaPlayer.h>
#import <MobileVLCKit/VLCMedia.h>

using namespace facebook::react;

@interface AdvanceVideoPlayerView () <RCTAdvanceVideoPlayerViewViewProtocol, VLCMediaPlayerDelegate, VLCMediaDelegate>

@end

@implementation AdvanceVideoPlayerView {
  AdvanceVideoPlayer * _player;
  BOOL _videoLoaded;
  BOOL _buffering;
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
  
    if (oldViewProps.aspectRatio != newViewProps.aspectRatio) {
        _player.aspectRatio = newViewProps.aspectRatio;
    }
    
    if (oldViewProps.audioTrack != newViewProps.audioTrack) {
        _player.audioTrack = newViewProps.audioTrack;
    }
  
    if (oldViewProps.audioTrack != newViewProps.audioTrack) {
      _player.textTrack = newViewProps.textTrack;
    }

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> AdvanceVideoPlayerViewCls(void)
{
    return AdvanceVideoPlayerView.class;
}

// MARK: - VLCMediaPlayerDelegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{
  if ([aNotification.object isKindOfClass:[VLCMediaPlayer class]]) {
    VLCMediaPlayer *player = (VLCMediaPlayer *)aNotification.object;
    VLCMediaPlayerState state = player.state;
    const auto eventEmitter = [self getEventEmitter];
    switch (state) {
      case VLCMediaPlayerStateOpening:
        NSLog(@"Opening Player");
        break;
      case VLCMediaPlayerStatePaused:
        eventEmitter->onPaused({});
        break;
      case VLCMediaPlayerStateStopped:
        eventEmitter->onStop({});
        break;
      case VLCMediaPlayerStateBuffering:
        if (!_videoLoaded && player.numberOfVideoTracks > 0) {
          _videoLoaded = YES;
          eventEmitter->onLoad(AdvanceVideoPlayerViewEventEmitter::OnLoad{
            .titles = [[player.titleDescriptions componentsJoinedByString:@","] UTF8String],
            .subtitleTracksIndexes = [[player.videoSubTitlesIndexes componentsJoinedByString:@","] UTF8String],
            .subtitleTracksNames = [[player.videoSubTitlesNames componentsJoinedByString:@","] UTF8String],
            .audioTracksIndexes = [[player.audioTrackIndexes componentsJoinedByString:@","] UTF8String],
            .audioTracksNames = [[player.audioTrackNames componentsJoinedByString:@","] UTF8String],
            .videoSize = AdvanceVideoPlayerViewEventEmitter::OnLoadVideoSize{
//              .height = player.videoSize.height,
//              .width = player.videoSize.width,
              .height = 1000,
              .width = 1900,
            },
            .duration = 12.0,
            .aspectRatio = [@"16:9" UTF8String]//player.videoAspectRatio,
          });
        }
        if (!_buffering) {
          eventEmitter->onBuffer(AdvanceVideoPlayerViewEventEmitter::OnBuffer{
            .buffering = true
          });
          _buffering = YES;
        }
        break;
      case VLCMediaPlayerStatePlaying:
        if (!player.isPlaying) {
          [_player onPlay];
        }
        _buffering = FALSE;
        eventEmitter->onBuffer(AdvanceVideoPlayerViewEventEmitter::OnBuffer{
          .buffering = false
        });
        break;
      case VLCMediaPlayerStateEnded:
        eventEmitter->onEnd({});
        break;
      case VLCMediaPlayerStateESAdded:
        RCTLog(@"VLCMediaPlayer Elementary Stream added: %d", player.currentTitleIndex);
        break;
      case VLCMediaPlayerStateError:
        NSString *errorString = [NSString stringWithFormat:@"[VLCMediaPlayerStateError]:%d", player.numberOfAudioTracks];
        eventEmitter->onError(AdvanceVideoPlayerViewEventEmitter::OnError{
          .error = [errorString UTF8String]
        });
        break;
    }
  }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
  if ([aNotification.object isKindOfClass:[VLCMediaPlayer class]]) {
    VLCMediaPlayer *player = (VLCMediaPlayer *)aNotification.object;
    const auto eventEmitter = [self getEventEmitter];
//    eventEmitter->onProgress(AdvanceVideoPlayerViewEventEmitter::OnProgress{
//      .currentTime = player.time,
//      .remainingTime = player.remainingTime,
//      .position = player.position,
//    });
  }
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
//  RCTLog(@"mediaPlayerLoudnessChanged: %@", aNotification);
}

- (void) mediaPlayerStartedRecording:(VLCMediaPlayer *)player
{
  RCTLog(@"mediaPlayerStartedRecording");
}

- (void) mediaPlayer:(VLCMediaPlayer *)player recordingStoppedAtPath:(NSString *) path
{
  RCTLog(@"mediaPlayer recordingStoppedAtPath: %@", path);
}

// MARK: - VLCMediaDelegate
- (void)mediaDidFinishParsing:(VLCMedia *)media
{
//  metaData.title, metaData.artist, metaData.albumArtist, metaData.album, metaData.genre, metaData.trackNumber, metaData.discNumber, metaData.artworkURL
  VLCMediaMetaData *metaData = media.metaData;
  NSLog(@"Meta data:%@", metaData);
//  const auto eventEmitter = [self getEventEmitter];
//  eventEmitter->onMediaMetaData(AdvanceVideoPlayerViewEventEmitter::OnMediaMetaData{
//    .title = [metaData.title UTF8String],
//    .artist = [metaData.artist UTF8String],
//    .albumArtist = [metaData.albumArtist UTF8String],
//  });
}

@end
