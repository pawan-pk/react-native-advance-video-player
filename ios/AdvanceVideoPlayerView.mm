#import "AdvanceVideoPlayerView.h"

#import <AdvanceVideoPlayer/ComponentDescriptors.h>
#import <AdvanceVideoPlayer/EventEmitters.h>
#import <AdvanceVideoPlayer/Props.h>
#import <AdvanceVideoPlayer/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"
#import "AdvanceVideoPlayer-Swift.h"
#import "RCTConvert+MediaTrack.h"

#import <VLCKit/VLCMediaPlayerTitleDescription.h>
#import <VLCKit/VLCMediaMetaData.h>
#import <VLCKit/VLCMediaPlayer.h>
#import <VLCKit/VLCMedia.h>
#import <VLCKit/VLCTime.h>

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
    _player.mediaDelegate = self;
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

// MARK: - Helper Functions
NSString *jsonStringFromArray(NSMutableArray *jsonArray)
{

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        NSLog(@"JSON serialization error: %@", error.localizedDescription);
        return nil;
    }

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

NSString *jsonArrayFromObject(NSArray<VLCMediaPlayerTrack *> *tracks) {
  NSMutableArray *jsonArray = [NSMutableArray array];
  
  for (VLCMediaPlayerTrack *track in tracks) {
    NSDictionary *dict = @{
      @"id": @(track.identifier),
      @"album": track.trackDescription ?: @"",
    };
    [jsonArray addObject:dict];
  }
  
  return jsonStringFromArray(jsonArray);
}

NSString *jsonArrayFromObject(NSArray<VLCMediaPlayerTitleDescription *> *titles) {
  NSMutableArray *jsonArray = [NSMutableArray array];
  
  for (VLCMediaPlayerTitleDescription *title in titles) {
    NSDictionary *dict = @{
      @"index": @(title.titleIndex),
      @"name": title.name ?: @"",
    };
    [jsonArray addObject:dict];
  }
  
  return jsonStringFromArray(jsonArray);
}

// MARK: - VLCMediaPlayerDelegate
- (void)mediaPlayerStateChanged:(VLCMediaPlayerState)newState
{
  VLCMediaPlayer *player = _player.player;
  const auto eventEmitter = [self getEventEmitter];
  switch (newState) {
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
      if (!_videoLoaded && player.videoTracks.count > 0) {
        _videoLoaded = YES;
        eventEmitter->onLoad(AdvanceVideoPlayerViewEventEmitter::OnLoad{
          .titles = [jsonArrayFromObject(player.titleDescriptions) UTF8String],
          .videoTracks = [jsonArrayFromObject(player.videoTracks) UTF8String],
          .audioTracks = [jsonArrayFromObject(player.audioTracks) UTF8String],
          .textTracks = [jsonArrayFromObject(player.textTracks) UTF8String],
          .duration = [player.media.length intValue],
//          .videoSize = AdvanceVideoPlayerViewEventEmitter::OnLoadVideoSize{
//            .height = player.videoSize.height,
//            .width = player.videoSize.width,
//          },
//            .aspectRatio = [player.videoAspectRatio UTF8String],
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
      _buffering = FALSE;
      eventEmitter->onBuffer(AdvanceVideoPlayerViewEventEmitter::OnBuffer{
        .buffering = false
      });
      break;
    case VLCMediaPlayerStateStopping:
      NSLog(@"Stopping Player");
      break;
    case VLCMediaPlayerStateError:
      eventEmitter->onError(AdvanceVideoPlayerViewEventEmitter::OnError{
        .error = [@"[VLCMediaPlayer error]" UTF8String]
      });
      break;
  }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
  if ([aNotification.object isKindOfClass:[VLCMediaPlayer class]]) {
    VLCMediaPlayer *player = (VLCMediaPlayer *)aNotification.object;
    const auto eventEmitter = [self getEventEmitter];
    eventEmitter->onProgress(AdvanceVideoPlayerViewEventEmitter::OnProgress{
      .currentTime = [player.time intValue],
      .remainingTime = [player.remainingTime intValue],
      .position = player.position,
    });
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

// MARK: - VLCMediaDelegate
- (void)mediaDidFinishParsing:(VLCMedia *)media
{
  VLCMediaMetaData *metaData = media.metaData;
  const auto eventEmitter = [self getEventEmitter];
  eventEmitter->onMediaMetaData(AdvanceVideoPlayerViewEventEmitter::OnMediaMetaData{
      .title = metaData.title ? [metaData.title UTF8String] : "",
      .artist = metaData.artist ? [metaData.artist UTF8String] : "",
      .albumArtist = metaData.albumArtist ? [metaData.albumArtist UTF8String] : "",
      .album = metaData.album ? [metaData.album UTF8String] : "",
      .genre = metaData.genre ? [metaData.genre UTF8String] : "",
      .trackNumber = static_cast<int>(metaData.trackNumber),
      .discNumber = static_cast<int>(metaData.discNumber),
      .artworkURL = metaData.artworkURL ? [[metaData.artworkURL absoluteString] UTF8String] : "",
  });
}

@end
