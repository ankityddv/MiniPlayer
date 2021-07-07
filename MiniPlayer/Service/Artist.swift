//
//  Artist.swift
//  MiniPlayer
//
//  Created by Ankit Yadav on 04/07/21.
//

import Foundation

struct Artist: Equatable {
    var uid: String // you can use username of artist as uid (it'll be unique obviously lol)
    var name: String
    var profileImageUrl: String
    var albumsId: [String]
    var tracksId: [String]
    var isVerified: Bool
    var followers: Int
    var origin: String
}
