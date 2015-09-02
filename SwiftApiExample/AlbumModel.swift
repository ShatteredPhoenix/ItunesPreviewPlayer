//
//  Album.swift
//  WeatherApp
//
//  Created by Humza Ahmed on 31/08/2015.
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

// just holds a few properties about albums for us
struct AlbumModel {
    let title: String
    let price: String
    let thumbnailImageURL: String
    let largeImageURL: String
    let itemURL: String
    let artistURL: String
    let collectionID: Int
    
    init(name: String, price: String, thumbnailImageURL: String, largeImageURL: String, itemURL: String, artistURL: String, collectionId: Int) {
        self.title = name
        self.price = price
        self.thumbnailImageURL = thumbnailImageURL
        self.largeImageURL = largeImageURL
        self.itemURL = itemURL
        self.artistURL = artistURL
        self.collectionID = collectionId
    }
    
    
    //Static Function
    static func albumsWithJSON(results: NSArray) -> [AlbumModel] {
        // Create an empty array of Albums to append to from this list
        var albums = [AlbumModel]()
        
        // Store the results in table data array
        if results.count>0 {
            
            // Sometimes iTunes returns a collection, not a track, so check both for the 'name'
            for result in results {
                
                var name = result["trackName"] as? String
                if name == nil {
                    name = result["collectionName"] as? String
                }
                
                // Sometimes price comes in as formattedPrice, sometimes as collectionPrice.. and sometimes it's a float instead of a string.
                var price = result["formattedPrice"] as? String
                
                if price == nil {
                    price = result["collectionPrice"] as? String
                    if price == nil {
                        var priceFloat: Float? = result["collectionPrice"] as? Float
                        var nf: NSNumberFormatter = NSNumberFormatter()
                        nf.maximumFractionDigits = 2
                        
                        //If all else fails and a price is not found the album will be deemed free
                        if price == nil {price = "Free"}
                        
                        if priceFloat != nil {
                            price = "$\(nf.stringFromNumber(priceFloat!)!)"
                        }
                    }
                }
                
                let thumbnailURL = result["artworkUrl60"] as? String ?? ""
                let imageURL = result["artworkUrl100"] as? String ?? ""
                let artistURL = result["artistViewUrl"] as? String ?? ""
                
                var itemURL = result["collectionViewUrl"] as? String
                if itemURL == nil {
                    itemURL = result["trackViewUrl"] as? String
                }
                
                //bundle the whole album creation inside of an if let clause so that only valid albums will show up on the list
                if let collectionId = result["collectionId"] as? Int {
                    var newAlbum = AlbumModel(name: name!,
                        price: price!,
                        thumbnailImageURL: thumbnailURL,
                        largeImageURL: imageURL,
                        itemURL: itemURL!,
                        artistURL: artistURL,
                        collectionId: collectionId)
                    albums.append(newAlbum)
                }
            }
        }
        return albums
    }}

