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
  
  // MARK: - Varibales
  @objc public var url: String? {
    didSet {
      setupPlayerView()
    }
  }
  @objc public var rate: Double = 1.0 {
    didSet {
      player.rate = Float(rate)
    }
  }
  @objc public var muted: Bool = false {
    didSet {
      player.audio?.isMuted = muted
    }
  }
  @objc public var volume: Double = 100.0 {
    didSet {
      player.audio?.volume = Int32(volume)
    }
  }
  @objc public var paused: Bool = false {
    didSet {
      paused ? player.pause() : player.play()
    }
  }
  @objc public var aspectRatio: Double = .zero {
    didSet {
      print("Resize mode: \(aspectRatio) not implemented")
    }
  }

  @objc public var audioTrack: Int = 1
  @objc public var textTrack: Int = 1
  
  @objc public func onPlay() {
    self.overlayView.removeFromSuperview()
  }

  @objc public var delegate: VLCMediaPlayerDelegate?
  @objc public var mediaDelegate: VLCMediaDelegate?
  
  private var player: VLCMediaPlayer = {
    let player = VLCMediaPlayer()
    return player
  }()

  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(playerView)
    
    NSLayoutConstraint.activate([
      playerView.topAnchor.constraint(equalTo: self.topAnchor),
      playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
  }
  
  func setupPlayerView() {
    if let urlString = url,
       let url = URL(string: urlString) {
      configureVLCPlayer(url)
      player.delegate = delegate
    } else {
      playerView.isHidden = true
      print("No channel URL found.")
    }
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

  private func configureVLCPlayer(_ url: URL) {
    let media = VLCMedia(url: url)
    // https://stackoverflow.com/a/41961321/3614746
    let options: [String] = [
      // "network-caching=150",
      // "network-caching=3000",
      "clock-jitter=0",
      "clock-synchro=0",
      "drop-late-frames",
      "skip-frames"
    ]
    for option in options {
      media.addOption("--\(option)")
      media.addOption(":\(option)")
    }
//    media.delegate = mediaDelegate
//    media.parse(options: [.parseNetwork,.fetchNetwork,.fetchLocal], timeout: 30)
    player.setDeinterlaceFilter(nil)
    player.adjustFilter.isEnabled = false
    player.media = media
    player.drawable = playerView
    player.audio?.isMuted = muted
    if !paused {
      player.play()
    }
    
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(overlayView)
    NSLayoutConstraint.activate([
      self.leftAnchor.constraint(equalTo: overlayView.leftAnchor),
      self.rightAnchor.constraint(equalTo: overlayView.rightAnchor),
      self.topAnchor.constraint(equalTo: overlayView.topAnchor),
      self.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor)
    ])
  }
}
