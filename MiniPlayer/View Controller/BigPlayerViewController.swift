//
//  MiniPlayerViewController.swift
//  MiniPlayer
//
//  Created by Ankit Yadav on 04/07/21.
//

import UIKit
import AVFoundation
import MediaPlayer

class BigPlayerViewController: UIViewController {

    var isComingFromMiniPlayer: Bool = false
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackProgressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var completeSongDurationLabel: UILabel!
    @IBOutlet weak var playBttn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [STEP-1] assign value to miniplayer
        let MiniPlayer = MiniPlayer.shared
        MiniPlayer.assignValuesFromBigPlayer(cover: self.coverImageView, trackName: self.trackNameLabel, artistName: self.artistNameLabel, slider: self.trackProgressSlider, currentDuration: self.currentTimeLabel, totalDuration: self.completeSongDurationLabel, playBttn: self.playBttn)
        // [STEP-2] call configure function
        configure()
        // setp 4
        MiniPlayer.setupMediaPlayerNoticationView()
    }
    // [Step-3] seup slider Action
    @IBAction func sliderValueDidChangeOnDrag(_ sender: Any) {
        MiniPlayer.shared.changeSliderValueOnDrag()
    }
    
}

extension BigPlayerViewController {
    func configure() {
        // check if user is coming from mini player of by tapping the main cell
        if isComingFromMiniPlayer {
            // We're not configuring the player again here because song is already playing and we don't want to have 2 songs playing at the same time
            let MiniPlayer = MiniPlayer.shared
            let currentPlayingList = MiniPlayer.currentPlayingList()
            let indexPathRow = MiniPlayer.indexPathRow()
            let trackToPlay = currentPlayingList[indexPathRow]

            MiniPlayer.configBigPlayerUI(track: trackToPlay)
        } else {
            let MiniPlayer = MiniPlayer.shared
            let currentPlayingList = MiniPlayer.currentPlayingList()
            let indexPathRow = MiniPlayer.indexPathRow()
            let trackToPlay = currentPlayingList[indexPathRow]
            
            DispatchQueue.main.async {
                MiniPlayer.configBigPlayerUI(track: trackToPlay)
            }
        }
    }
    // to update now playing in notification center
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let MiniPlayer = MiniPlayer.shared
        var nowPlayingInfo = MiniPlayer.nowPlayingInfo
        if object is AVPlayer {
            switch MiniPlayer.player!.timeControlStatus {
            case .waitingToPlayAtSpecifiedRate,.paused:
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(MiniPlayer.player!.currentTime())
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
                MPNowPlayingInfoCenter.default ().nowPlayingInfo = nowPlayingInfo
            case .playing:
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime ] = CMTimeGetSeconds(MiniPlayer.player!.currentTime())
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
                MPNowPlayingInfoCenter.default ().nowPlayingInfo = nowPlayingInfo
            @unknown default:
                break
            }
        }
    }
    @objc func backwardBttnDidTap() {
        let MiniPlayer = MiniPlayer.shared
        MiniPlayer.backwardBttnInBigPlayerDidTap()
    }
    @objc func playBttnDidTap() {
        let MiniPlayer = MiniPlayer.shared
        
        MiniPlayer.playOrPause()
        // show play/pause button
        MiniPlayer.setPlayBttnImage(playBttn)
        // show play/pause for MiniPlayer button
        MiniPlayer.setPlayBttnImage(MiniPlayer.bigPlayerPlayBttn!)
        // shrink image and send back to normal
        MiniPlayer.setImageAnimation(coverImageView)
    }
    @objc func forwardBttnDidTap() {
        let MiniPlayer = MiniPlayer.shared
        MiniPlayer.forwardBttnInBigPlayerDidTap()
    }
}
