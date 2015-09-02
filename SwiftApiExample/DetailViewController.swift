//
//  DetailViewController.swift
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
import MediaPlayer
import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    //Media Player
    var MediaPlayer: MPMoviePlayerController = MPMoviePlayerController()
    
    //lazy keyword to indicate we don’t want the APIController instance api to be instantiated until it is used.
    lazy var API : APIController = APIController(delegate: self)
    
    //Album Image
    @IBOutlet weak var AlbumImage: UIImageView!
    
    //Title Label
    @IBOutlet weak var TitleLabel: UILabel!
    
    //Tracks Table View
    @IBOutlet weak var TracksTableView: UITableView!
    
    //Array of Tracks
    var Tracks = [TrackModel]()
    
    var album: AlbumModel?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 /*------------------------------------------------------------------------------------------------------*/
                                        /*View Did Load Function*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Title Label to almbum Title
        TitleLabel.text = self.album?.title
        
        //Set Image to Album Image
        AlbumImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: self.album!.largeImageURL)!)!)
        
        // Load in tracks
        if self.album != nil {
            API.lookupAlbum(self.album!.collectionID)
        }
    }
    
    /*---------------------------------------------------------------------------------------------------*/
                                    /*Various Table Functions*/
    //Return number of Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Tracks.count
    }
    
    //Fill Row with Track Data 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackCell") as! TrackCell
        let track = Tracks[indexPath.row]
        cell.TrackTitleLabel.text = track.title

        return cell
    }
    
    //Play Preview of Track from Whatever Row is Tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var track = Tracks[indexPath.row]
       
        
        MediaPlayer.contentURL = NSURL(string: track.previewUrl) // Take content from preview URL
    
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TrackCell {
                
                //if cell icon = Play Icon
                if cell.PlayIcon.text == "▶️"
                {
                    MediaPlayer.play() // Play Media
                    cell.PlayIcon.text = "⬛️" //Change Button to Stop Icon
                    
                }
                else if cell.PlayIcon.text == "⬛️" //Else if icon is Stop Icon
                {
                 MediaPlayer.stop() //Stop Media
                 cell.PlayIcon.text = "▶️" //Change Button Back to Play
                }
                
              
            }
            
            
        
        
       
        
    }
    
    //Animation Function - Before Cell is Displayed
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //  uses CATransform3DMakeScale() to create a transform matrix that scales down any object in x, y, and z
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        
       // Next we set the cell layer’s transform to a new scale, this time of (1,1,1
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }
    /*---------------------------------------------------------------------------------------------------*/
    
    // MARK: APIControllerProtocol
    func didReceiveAPIResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue(), {
            self.Tracks = TrackModel.tracksWithJSON(results)
            self.TracksTableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
}