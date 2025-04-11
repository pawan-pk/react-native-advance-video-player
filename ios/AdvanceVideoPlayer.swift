//
//  AdvanceVideoPlayer.swift
//  AdvanceVideoPlayer
//
//  Created by Pawan Kushwaha on 08/04/25.
//
import UIKit
import MobileVLCKit
import AVFoundation
import AVKit

@objc(AdvanceVideoPlayer)
public class AdvanceVideoPlayer: UIView {
  // MARK: - Views
  private lazy var playerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .black
    return view
  }()
  
  private lazy var overlayView: UIView = {
    let blurEffect = UIBlurEffect(style: .regular)
    let blurVIew = UIVisualEffectView(effect: blurEffect)
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    blurVIew.contentView.addSubview(indicator)
    NSLayoutConstraint.activate([
      blurVIew.contentView.centerXAnchor.constraint(equalTo: indicator.centerXAnchor),
      blurVIew.contentView.centerYAnchor.constraint(equalTo: indicator.centerYAnchor)
    ])
    indicator.startAnimating()
    return blurVIew
  }()
  
  lazy var debugView: UILabel = {
    let view = UILabel()
    view.font = .preferredFont(forTextStyle: .footnote)
    view.textColor = .tertiaryLabel
    view.numberOfLines = 0
    return view
  }()
  
  // MARK: - Varibales
  @objc var url: NSURL?
  private var player: PlayerInterface = EmptyPlayer()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    print("LOG: init(frame: CGRect)")
    
    debugView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(playerView)
    self.addSubview(debugView)
    
    NSLayoutConstraint.activate([
      playerView.topAnchor.constraint(equalTo: self.topAnchor),
      playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
    
    NSLayoutConstraint.activate([
      self.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: debugView.leftAnchor),
      self.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: debugView.rightAnchor),
      self.safeAreaLayoutGuide.topAnchor.constraint(equalTo: debugView.topAnchor)
    ])
    
    setupPlayerView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    print("LOG: layoutSubviews")
  }
  
  func setupPlayerView() {
//    if let url {
//      self.player = configureVLCPlayer(url as URL)
      let _url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
      self.player = configureVLCPlayer(_url)
      self.player.play()
//    } else {
//      playerView.isHidden = true
//      print("No channel URL found.")
//    }
  }
  
  public override func removeFromSuperview() {
    super.removeFromSuperview()
    // cleanup and teardown any existing resources
    if player.isPlaying {
      player.pause()
    }
  }
  
  deinit {
    player.stop()
  }
  
  // There are freezes for 1080p (buffering issue).
  // That is why better use native player.
  private func configureVLCPlayer(_ url: URL) -> PlayerInterface {
    let mediaPlayer = VLCMediaPlayer()
    let media = VLCMedia(url: url)
    // https://stackoverflow.com/a/41961321/3614746
    let options: [String] = [
//    "network-caching=150",
//    "network-caching=3000",
      "clock-jitter=0",
      "clock-synchro=0",
      "drop-late-frames",
      "skip-frames"
    ]
    for option in options {
      media.addOption("--\(option)")
      media.addOption(":\(option)")
    }
    
    mediaPlayer.setDeinterlaceFilter(nil)
    mediaPlayer.adjustFilter.isEnabled = false
    mediaPlayer.media = media
    mediaPlayer.drawable = playerView
    
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(overlayView)
    NSLayoutConstraint.activate([
      self.leftAnchor.constraint(equalTo: overlayView.leftAnchor),
      self.rightAnchor.constraint(equalTo: overlayView.rightAnchor),
      self.topAnchor.constraint(equalTo: overlayView.topAnchor),
      self.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor)
    ])
    
    return VlcPlayer(player: mediaPlayer, onPlay: { [weak self] in
      print("LOG: onPlay:", mediaPlayer.isPlaying)
      DispatchQueue.main.async {
        self?.overlayView.removeFromSuperview()
      }
    }, onError: { error in
      print("LOG: Plabcak error: \(error)")
    })
  }
}

private protocol PlayerInterface {
  var isPlaying: Bool {get}
  var onError: ((Error) -> Void)? {get}
  
  func play()
  func pause()
  func stop()
}

private final class VlcPlayer: NSObject, PlayerInterface, VLCMediaPlayerDelegate {
  private let player: VLCMediaPlayer
  private let onPlay: () -> Void
  var onError: ((Error) -> Void)?
  
  init(player: VLCMediaPlayer, onPlay: @escaping () -> Void, onError: @escaping (Error) -> Void) {
    self.player = player
    self.onPlay = onPlay
    self.onError = onError
    super.init()
    player.delegate = self
  }
  
  var isPlaying: Bool { player.isPlaying }
  func play() { player.play() }
  func pause() { player.pause() }
  func stop() { player.stop() }
  
  func mediaPlayerStateChanged(_ aNotification: Notification) {
  }
  
  func mediaPlayerTimeChanged(_ aNotification: Notification) {
    player.delegate = nil
    DispatchQueue.main.async {
      self.onPlay()
    }
  }
  func mediaPlayerTitleChanged(_ aNotification: Notification) {
  }
  func mediaPlayerChapterChanged(_ aNotification: Notification) {
  }
  func mediaPlayerSnapshot(_ aNotification: Notification) {
  }
  func mediaPlayerStartedRecording(_ player: VLCMediaPlayer) {
  }
  func mediaPlayer(_ player: VLCMediaPlayer, recordingStoppedAtPath path: String) {
  }
}

private final class EmptyPlayer: PlayerInterface {
  var isPlaying: Bool { false }
  var onError: ((Error) -> Void)?
  func play() { }
  func pause() { }
  func stop() { }
}
