import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps } from 'react-native';
import type {
  DirectEventHandler,
  Double,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypes';

// type MediaTrack = {
//   id: Int32;
//   name: string;
// };

type MediaProgress = {
  currentTime: Double;
  remainingTime: Double;
  position: Double;
};

type VLCMedia = {
  subtitle: string;
  // audioTracks: ReadonlyArray<MediaTrack>;
  // textTracks: ReadonlyArray<MediaTrack>;
  videoSize: {
    width: Double;
    height: Double;
  };
  duration: Double;
  aspectRatio: Double;
};

interface NativeProps extends ViewProps {
  url?: string;
  rate?: Double;
  muted?: boolean;
  volume?: Double;
  paused?: boolean;
  aspectRatio?: Double;
  selectedAudioTrack?: Int32;
  selectedTextTrack?: Int32;

  onLoad?: DirectEventHandler<VLCMedia>;
  onPaused?: DirectEventHandler<{}>;
  onEnd?: DirectEventHandler<{}>;
  onStop?: DirectEventHandler<{}>;
  onError?: DirectEventHandler<{ error: string }>;
  onBuffer?: DirectEventHandler<{ buffering: boolean }>;
  onProgress?: DirectEventHandler<MediaProgress>;
}

export default codegenNativeComponent<NativeProps>('AdvanceVideoPlayerView');
