//
//  MiniPlayer.swift
//  MiniPlayer
//
//  Created by Ankit Yadav on 04/07/21.
//

import UIKit
import Foundation
import MediaPlayer
import AVFoundation

class MiniPlayer {
    
    var player: AVPlayer!
    var nowPlayingInfo = [String : Any]()
    
    static let shared = MiniPlayer()
    
    // values for BigPlayerVC
    var timer: Timer!
    var bigPlayerTrackNameLabel: UILabel?
    var bigPlayerArtistNameLabel: UILabel?
    var bigPlayerCurrentTimeLabel: UILabel?
    var bigPlayerCompleteSongDurationLabel: UILabel?
    var bigPlayerTrackProgressSlider: UISlider?
    var bigPlayerPlayBttn: UIButton?
    var bigPlayerCoverImageView: UIImageView?
    
    // assign values to above variables
    func assignValuesFromBigPlayer(cover: UIImageView, trackName: UILabel, artistName: UILabel, slider: UISlider, currentDuration: UILabel, totalDuration: UILabel, playBttn: UIButton) {
        let MiniPlayer = MiniPlayer.shared
        MiniPlayer.bigPlayerCoverImageView = cover
        MiniPlayer.bigPlayerTrackNameLabel = trackName
        MiniPlayer.bigPlayerArtistNameLabel = artistName
        MiniPlayer.bigPlayerTrackProgressSlider = slider
        MiniPlayer.bigPlayerCurrentTimeLabel = currentDuration
        MiniPlayer.bigPlayerCompleteSongDurationLabel = totalDuration
        MiniPlayer.bigPlayerPlayBttn = playBttn
    }
    
    func configure(track: Track) {
        // get song data
        let name = track.name
        let artistId = track.artistId[0]
        let artist = ArtistService.shared.getArtist(byId: artistId).name
        let albumId = track.albumId
        let album = ArtistService.shared.getAlbum(byId: albumId).name
        let genre = track.genres
        let urlString = track.urlString
        let cover = track.cover // give input for your cover to display in control center
        
        do {
            // to support media playing in background
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            
            player = AVPlayer(url: URL(string: urlString)!)
            player.play()
            
            guard let player = player else {return}
            
            
            // if there's already a song playing, then stop that and start selected song
            if player.isPlaying {
                player.pause()
            }
            
            // to set play icon in playbttn in HomeVC when a song is forwarded when paused from PlayerVC
            if self.MiniPlayerPlayBttnIn != nil {
                setPlayBttnImage(self.MiniPlayerPlayBttnIn!)
            }
            
            // Define Now Playing Info
            nowPlayingInfo[MPMediaItemPropertyTitle] = name
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
            nowPlayingInfo[MPMediaItemPropertyGenre] = genre
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
            if let image = cover {
                nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: image.size) { size in
                        return image
                }
            }
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.asset.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
            // Set the metadata
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                
            // To seek through the track from notification center
            let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.changePlaybackPositionCommand.addTarget { [weak self](remoteEvent) -> MPRemoteCommandHandlerStatus in
                guard let self = self else {return .commandFailed}
                let playerRate = player.rate
                if let event = remoteEvent as? MPChangePlaybackPositionCommandEvent {
                    player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(1000)), completionHandler: { [weak self](success) in
                        guard self != nil else {return}
                        if success {
                            player.rate = playerRate
                        }
                    })
                    return .success
                 }
                return .commandFailed
            }
            // Register to receive events
            UIApplication.shared.beginReceivingRemoteControlEvents()
            print("Player configured ✅")
        } catch {
            print(error)
        }
    }
    
    // update chnages in Player's UI located in BigPlayerViewController
    func configBigPlayerUI(track: Track){
        // get song data
        let cover = track.cover
        let name = track.name
        let artistId = track.artistId[0]
        let artist = ArtistService.shared.getArtist(byId: artistId).name
        
        // update UI
        if bigPlayerCoverImageView != nil {
            bigPlayerCoverImageView?.image = cover
        }
        if bigPlayerTrackNameLabel != nil {
            bigPlayerTrackNameLabel!.text = name
        }
        if bigPlayerArtistNameLabel != nil {
            bigPlayerArtistNameLabel!.text = artist
        }
        // check if song progress slider is refferd from BigPlayerVC or not
        if bigPlayerTrackProgressSlider != nil {
            // schedule timer
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeSliderValueWithTimer), userInfo: nil, repeats: true)
            setPlayBttnImage(bigPlayerPlayBttn!)
            // song progress slider
            bigPlayerTrackProgressSlider!.minimumValue = 0.0
            // get song's total duration
//            guard let player = player else {
//                print("player nor found")
//                return
//            }
            DispatchQueue.main.async {
                let duration = self.player.currentItem?.asset.duration
                self.bigPlayerCompleteSongDurationLabel!.text = duration?.minutes
                self.bigPlayerTrackProgressSlider!.maximumValue = Float(CMTimeGetSeconds(duration!))
            }
        }
    }
    
    // values for MiniPlayer in HomeViewController
    var miniPlayerCoverImageView:UIImageView?
    var miniPlayerSongNameLabel: UILabel?
    var miniPlayerArtistNameLabel: UILabel?
    var MiniPlayerPlayBttnIn: UIButton?
    
    // update chnages in MiniPlayer's UI located in HomeVC
    func configMiniPlayerUI(track: Track) {
        let cover = track.cover
        let name = track.name
        let artistId = track.artistId[0]
        let artist = ArtistService.shared.getArtist(byId: artistId).name
        
        if miniPlayerCoverImageView != nil {
            miniPlayerCoverImageView?.image = cover
        }
        if miniPlayerSongNameLabel != nil {
            miniPlayerSongNameLabel!.text = name
        }
        if miniPlayerArtistNameLabel != nil {
            miniPlayerArtistNameLabel!.text = artist
        }
    }
    
    func playOrPause() {
        /*
        check if song is playing() -> pause
        else play track
        */
        switch TrackService.shared.checkIfPaused() {
        case .isPausedd:
            player.play()
            break
        case .isPlayingg:
            player.pause()
            break
        case .undefined:
            break
        }
    }
    func forward(indexPathRow: Int, tracks: [Track]) {
        // pause the song
        player.pause()
        // animate cover image of Main Player Screen to identity with a little pop out animation
        if bigPlayerCoverImageView!.image != nil {
            bigPlayerCoverImageView!.toIdentity(1.05)
        }
        // configure a new player with next song in current playing list/array
        configure(track: tracks[indexPathRow])
    }
    func backward(indexPathRow: Int, tracks: [Track]) {
        // play the song
        player.pause()
        // animate cover image of Main Player Screen to identity with a little pop out animation
        if bigPlayerCoverImageView!.image != nil {
            bigPlayerCoverImageView!.toIdentity(1.05)
        }
        // configure a new player with previous song in current playing list/array
        configure(track: tracks[indexPathRow])
    }
    
    // call this function for miniplayer (located in toolbar) forwardBttn
    @objc func forwardBttnDidTap() {
        let tracks = currentPlayingList()
        var indexPathRow = indexPathRow()
        
        // change the position of song in an array
        if indexPathRow < (tracks.count - 1) {
            indexPathRow = indexPathRow + 1
        }
        // update current playing value after change the position
        updateCurrentPlaying(tracks: tracks, indexPath: indexPathRow)
        // update changes in UI of miniPlayer
        configMiniPlayerUI(track: tracks[indexPathRow])
        // take user to next song
        forward(indexPathRow: indexPathRow, tracks: tracks)
    }
    // call this function for miniplayer (located in toolbar) backwardBttn
    @objc func backwardBttnDidTap() {
        let tracks = currentPlayingList()
        var indexPath = indexPathRow()
        
        // change the position of song in an array
        if indexPath>0 {
            indexPath = indexPath - 1
        }
        // update current playing value after change the position
        updateCurrentPlaying(tracks: tracks, indexPath: indexPath)
        // update changes in UI of miniPlayer
        configMiniPlayerUI(track: tracks[indexPath])
        // take user to previous song
        backward(indexPathRow: indexPath, tracks: tracks)
    }
    
    @objc func forwardBttnInBigPlayerDidTap() {
        forwardBttnDidTap()
        // the next song to play
        let trackToPlay = currentPlayingList()[indexPathRow()]
        // update changes in UI of Player
        configBigPlayerUI(track: trackToPlay)
    }
    @objc func backwardBttnInBigPlayerDidTap() {
        // the next song to play
        let trackToPlay = currentPlayingList()[indexPathRow()]
        // update changes in UI of Player
        configBigPlayerUI(track: trackToPlay)
    }
    // change values of slider and labe with timer
    @objc func changeSliderValueWithTimer() {
        bigPlayerCurrentTimeLabel!.text = player.currentTime().minutes
        UIView.animate(withDuration: 0.1, animations: {
            self.bigPlayerTrackProgressSlider!.setValue(Float(CMTimeGetSeconds(self.player.currentTime())), animated:true)
        })
    }
    // change value of audio's poition by dragging
    @objc func changeSliderValueOnDrag() {
        let seconds: Int64 = Int64(bigPlayerTrackProgressSlider!.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        // to update now playing in notification center
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(MiniPlayer.shared.player!.currentTime())
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        MiniPlayer.shared.player!.seek(to: targetTime) { (isCompleted) in
            // to update now playing in notification center
            self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(MiniPlayer.shared.player!.currentTime())
            self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
        }
        self.bigPlayerCurrentTimeLabel!.text = String(TimeInterval(bigPlayerTrackProgressSlider!.value).minutes())
    }
    
    func setPlayBttnImage(_ playBttn: UIButton) {
        switch TrackService.shared.checkIfPaused() {
        case .isPausedd:
            playBttn.play()
            break
        case .isPlayingg:
            playBttn.pause()
            break
        case .undefined:
            break
        }
    }
    func setImageAnimation(_ imageView: UIImageView){
        switch TrackService.shared.checkIfPaused() {
        case .isPausedd:
            imageView.shrink(0.8)
            break
        case .isPlayingg:
            imageView.toIdentity(1.02)
            break
        case .undefined:
            break
        }
    }
    // for the controls from notification center media player
    func setupMediaPlayerNoticationView(){
        let commandCenter = MPRemoteCommandCenter.shared()
        // Add handler for Play Command
        commandCenter.playCommand.addTarget{ event in
//            self.playBttnDidTap()
            return .success
        }
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget{event in
//            self.playBttnDidTap()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget{ event in
            self.backwardBttnDidTap()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { event in
            self.forwardBttnDidTap()
            return .success
        }
    }
    
    // Current Playing list
    func currentPlayingList() -> [Track]{
        let tracksList = currentPlayingInfo?.tracksList
        guard tracksList != nil else { return [Track(uid: "NaN", name: "NaN", albumId: "NaN", artistId: ["NaN"], genres: "", urlString: "Nan", cover: UIImage(named: "nil"))]}
        return tracksList!
    }
    func indexPathRow() -> Int{
        let indexPathRow = currentPlayingInfo?.indexPathRow
        guard indexPathRow != nil else {return 0}
        return indexPathRow!
    }
    func updateCurrentPlaying(tracks: [Track], indexPath: Int){
        currentPlayingInfo = CurrentPlaying(tracksList: tracks, indexPathRow: indexPath)
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension UIButton {
    func play() {
        self.setImage(UIImage(named: "play-icon"), for: .normal)
    }
    func pause() {
        self.setImage(UIImage(named: "pause-icon"), for: .normal)
    }
}

extension UIImageView {
    func shrink(_ by: CGFloat = 0.8) {
        UIView.animate(withDuration: 0.6,
            animations: {
                self.transform = CGAffineTransform(scaleX: by, y: by)
            },
            completion: nil)
    }
    func toIdentity(_ by: CGFloat = 0.05) {
        UIView.animate(withDuration: 0.6,
            animations: {
                self.transform = CGAffineTransform(scaleX: by, y: by)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.transform = CGAffineTransform.identity
                }
            })
    }
}

extension CMTime {
    var minutes:String {
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds % 3600 / 60)
        let seconds:Int = Int((totalSeconds % 3600) % 60)

        if hours > 0 {
            return String(format: "%i:%02i:%02i", minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

extension TimeInterval{
    func minutes() -> String {
        let time = NSInteger(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
}

//extension UIImageView {
//    func isEmpty() -> Bool{
//        let response: Bool?
//        if self == nil {
//            response = true
//        } else {
//            response = false
//        }
//        return response!
//    }
//}
