//
//  AdvanceVideoPlayer.swift
//  AdvanceVideoPlayer
//
//  Created by Pawan Kushwaha on 08/04/25.
//
import UIKit
import VLCKit
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
        if player.media == nil { return }
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

  @objc public var delegate: VLCMediaPlayerDelegate?
  @objc public var mediaDelegate: VLCMediaDelegate?
  
  @objc public var player: VLCMediaPlayer = VLCMediaPlayer()
  @objc public var media: VLCMedia?

  
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
    media = VLCMedia(url: url)
    guard let media else { return }
    
    // MARK: Media Parser
    media.delegate = mediaDelegate
    media.parse(options: [.parseNetwork,.fetchNetwork,.fetchLocal])
    
    // MARK: Player Initilization
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
    player.setDeinterlaceFilter(nil)
    player.adjustFilter.isEnabled = false
    player.media = media
    self.player.drawable = self.playerView
    player.audio?.isMuted = muted
    if !paused {
      player.play()
    }
  }
}
