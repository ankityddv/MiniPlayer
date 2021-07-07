//
//  CurrentPlaying.swift
//  MiniPlayer
//
//  Created by Ankit Yadav on 04/07/21.
//

import Foundation

var currentPlayingInfo: CurrentPlaying?

struct CurrentPlaying {
    var tracksList: [Track]
    var indexPathRow: Int
}
