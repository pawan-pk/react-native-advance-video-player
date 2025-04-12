import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps } from 'react-native';
import type {
  DirectEventHandler,
  Double,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypes';

type MediaProgress = {
  currentTime: Double;
  remainingTime: Double;
  position: Double;
};

type NativeMediaMetaData = {
  title: string;
  artist: string;
  albumArtist: string;
  album: string;
  genre: string;
  trackNumber: Int32;
  discNumber: Int32;
  artworkURL: string;
};

export type NativeVLCMedia = {
  titles: string;
  audioTracksIndexes: string;
  audioTracksNames: string;
  subtitleTracksIndexes: string;
  subtitleTracksNames: string;
  videoSize: {
    width: Double;
    height: Double;
  };
  duration: Double;
  aspectRatio: string;
};

interface NativeProps extends ViewProps {
  url?: string;
  rate?: Double;
  muted?: boolean;
  volume?: Double;
  paused?: boolean;
  aspectRatio?: Double;
  audioTrack?: Int32;
  textTrack?: Int32;

  onMediaMetaData?: DirectEventHandler<NativeMediaMetaData>;
  onLoad?: DirectEventHandler<NativeVLCMedia>;
  onPaused?: DirectEventHandler<{}>;
  onEnd?: DirectEventHandler<{}>;
  onStop?: DirectEventHandler<{}>;
  onError?: DirectEventHandler<{ error: string }>;
  onBuffer?: DirectEventHandler<{ buffering: boolean }>;
  onProgress?: DirectEventHandler<MediaProgress>;
}

export default codegenNativeComponent<NativeProps>('AdvanceVideoPlayerView');
