//
//  Track.swift
//  MiniPlayer
//
//  Created by Ankit Yadav on 04/07/21.
//

import UIKit
import Foundation

struct Track: Equatable {
    var uid: String
    var name: String
    var albumId: String
    var artistId: [String]
    var genres: String
    var urlString: String
    var cover: UIImage?
}
