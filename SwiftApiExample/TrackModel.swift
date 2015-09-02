//
//  Track.swift
//  WeatherApp
//
//  Created by Humza Ahmed on 01/09/2015.
//  Copyright (c) 2015 Humza Ahmed. All rights reserved.
//
/***********************************************************************
ItunesPreviewPlayer - Simple application that uses Swift with Itunes Search API to allow the user to search for any album and prieview the tracks within it.

Copyright (C) 2015 Humza Ahmed

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***********************************************************************/

import Foundation

struct TrackModel {
    let title: String
    let price: String
    let previewUrl: String
    
    init(title: String, price: String, previewUrl: String) {
        self.title = title
        self.price = price
        self.previewUrl = previewUrl
    }
    
    static func tracksWithJSON(results: NSArray) -> [TrackModel] {
        var tracks = [TrackModel]()
        for trackInfo in results {
            
            // Create the track
            if let kind = trackInfo["kind"] as? String {
                if kind=="song" {
                    var trackPrice = trackInfo["trackPrice"] as? String
                    var trackTitle = trackInfo["trackName"] as? String
                    var trackPreviewUrl = trackInfo["previewUrl"] as? String
                    if(trackTitle == nil) {
                        trackTitle = "Unknown"
                    }
                    else if(trackPrice == nil) {
                        println("No trackPrice in \(trackInfo)")
                        trackPrice = "?"
                    }
                    else if(trackPreviewUrl == nil) {
                        trackPreviewUrl = ""
                    }
                    var track = TrackModel(title: trackTitle!, price: trackPrice!, previewUrl: trackPreviewUrl!)
                    tracks.append(track)
                }
            }
        }
        return tracks
    }
}