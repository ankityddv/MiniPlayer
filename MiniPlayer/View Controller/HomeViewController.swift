//
//  HomeViewController.swift
//  MiniPlayer
//
//  Created by Ankit Yadav on 04/07/21.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let MiniPlayer = MiniPlayer.shared
        let TrackService = TrackService.shared
        
        let tracksToPlay = TrackService.getTracksToPlay()
        print("tracks to play \(tracksToPlay)")
        MiniPlayer.updateCurrentPlaying(tracks: tracksToPlay, indexPath: 0)
        
        let trackToPlay = MiniPlayer.currentPlayingList()[MiniPlayer.indexPathRow()]
        MiniPlayer.configure(track: trackToPlay)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BigPlayerViewController") as! BigPlayerViewController
            vc.isComingFromMiniPlayer = false
            self.present(vc, animated: true, completion: nil)
        }
        
        // check if any song is already playing in player, if so then remover the player and initiater a new one
        if TrackService.checkStatus() == .isPlayingg {
            MiniPlayer.player.pause()
            MiniPlayer.player = nil
        }
    }
}

