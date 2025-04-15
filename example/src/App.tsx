import { useState } from 'react';
import { Button, SafeAreaView, StyleSheet, Text, View } from 'react-native';
import AdvanceVideoPlayer from '@pawan-pk/react-native-advance-video-player';

export default function App() {
  const [paused, setPaused] = useState(false);
  const [muted, setMuted] = useState(false);
  const [rate, setRate] = useState(1.0);
  const [volume, setVolume] = useState(100);

  const volumeUp = () => {
    setVolume((prev) => (prev !== 200 ? prev + 10 : prev));
  };
  const volumeDown = () => {
    setVolume((prev) => (prev !== 0 ? prev - 10 : prev));
  };
  const rateUp = () => {
    setRate((prev) => (prev !== 1 ? Number((prev + 0.1).toFixed(1)) : prev));
  };
  const rateDown = () => {
    setRate((prev) => (prev !== 0 ? Number((prev - 0.1).toFixed(1)) : prev));
  };

  return (
    <SafeAreaView>
      <Text style={styles.title}>AdvanceVideoPlayer</Text>
      <AdvanceVideoPlayer
        url="http://mytv-extra.com:88/live/MRKKG6M9/CEG835RM/1045.m3u8"
        style={styles.container}
        paused={paused}
        muted={muted}
        volume={volume}
        onLoad={(data) => console.log('onLoad data:', data)}
        onError={(data) => console.log('onError data:', data)}
        onBuffer={(data) => console.log('onBuffer data:', data)}
        onProgress={(data) => console.log('onProgress data:', data)}
        onMediaMetaData={(data) => console.log('onMediaMetaData data:', data)}
      />
      <View style={styles.buttons}>
        <Button title="< -10 Sec" />
        <Button
          title={paused ? 'PLAY' : 'PAUSE'}
          onPress={() => setPaused((prev) => !prev)}
        />
        <Button title="10 Sec >" />
      </View>
      <View style={styles.buttons}>
        <Button title="Rate -" onPress={rateDown} />
        <Text>Rate {rate}</Text>
        <Button title="Rate +" onPress={rateUp} />
      </View>
      <View style={styles.buttons}>
        <Button title="Volume -" onPress={volumeDown} />
        <Text>Valume {volume}</Text>
        <Button title="Volume +" onPress={volumeUp} />
      </View>
      <View style={styles.buttons}>
        <Button
          title={muted ? 'Unmute' : 'Mute'}
          onPress={() => setMuted((prev) => !prev)}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    height: 300,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginVertical: 8,
  },
  buttons: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginHorizontal: 40,
    marginTop: 20,
  },
});
