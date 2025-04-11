#import "AdvanceVideoPlayerView.h"

#import <AdvanceVideoPlayer/ComponentDescriptors.h>
#import <AdvanceVideoPlayer/EventEmitters.h>
#import <AdvanceVideoPlayer/Props.h>
#import <AdvanceVideoPlayer/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"
#import "AdvanceVideoPlayer-Swift.h"

using namespace facebook::react;

@interface AdvanceVideoPlayerView () <RCTAdvanceVideoPlayerViewViewProtocol>

@end

@implementation AdvanceVideoPlayerView {
  AdvanceVideoPlayer * _player;
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
    self.contentView = _player;
  }

  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<AdvanceVideoPlayerViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<AdvanceVideoPlayerViewProps const>(props);

    if (oldViewProps.url != newViewProps.url) {
        NSString * urlToConvert = [[NSString alloc] initWithUTF8String: newViewProps.url.c_str()];
        NSURL *url = [self urlStringToURL:urlToConvert];
//        [_player setUrl:url];
    }

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> AdvanceVideoPlayerViewCls(void)
{
    return AdvanceVideoPlayerView.class;
}

- urlStringToURL:(NSString *)stringToConvert
{
    NSString *encodedString = [stringToConvert stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [NSURL URLWithString:encodedString];
}

@end
