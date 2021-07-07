//
//  TrackService.swift
//  MiniPlayer
//
//  Created by Ankit Yadav on 04/07/21.
//

import UIKit
import Foundation

enum TrackStatus {
    case isPlayingg
    case isPausedd
    case undefined
}

class TrackService {
    
    static let shared = TrackService()
    
    func getTracksToPlay() -> [Track] {
        var songsarr = [Track]()
        songsarr.append(Track(uid: "Sidhu1", name: "Sidhu Son", albumId: "moosetape", artistId: ["sidhu"], genres: "Punjabi", urlString: "https://dl.dropboxusercontent.com/s/0qbqiaoxpq4wgrp/SidhuSon.mp3?dl=0", cover: UIImage(named: "sidhu")))
        return songsarr
    }
    
    func checkStatus() -> TrackStatus {
        //using miniplayer to test player capabilities
        let player = MiniPlayer.shared.player
        guard player != nil else {
            return .isPausedd
        }
        return .isPlayingg
    }
    
    func checkIfPaused() -> TrackStatus {
        let player = MiniPlayer.shared.player
        guard player?.isPlaying != false else { return .isPausedd }
        return .isPlayingg
    }
    
    func sortBy(genres: String, arrayToSort: [Track]) -> [Track] {
        var sorted = [Track]()
        for song in arrayToSort {
            if song.genres == genres{
                sorted.append(song)
            }
        }
        return sorted
    }
    
    func checkIfAleradyPlaying() -> TrackStatus {
        let indexPathRow = currentPlayingInfo?.indexPathRow
        let currentPlaying = currentPlayingInfo?.tracksList[indexPathRow!]
        guard currentPlaying != nil else {
            return .undefined
        }
        if currentPlaying == nil {
            return .isPausedd
        }else {
            return .isPlayingg
        }
    }
}
