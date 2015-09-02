//
//  ViewController.swift
//  SwiftApiExample
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

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, APIControllerProtocol {
    
    //Will become a Lookup Dictionary
    var imageCache = [String:UIImage]()
    
    //Cell Idenftifier
    let kCellIdentifier: String = "SearchResultCell"
    
    //Creates empty array containing strictly Albums
    var Alb = [AlbumModel]()
    
    //Make Api Controller a Child Of View Controller - implicitly unwrapped optional
    var API : APIController!
    
    //Default Search Term Ed Sheeran
    var SearchTerm: String = "Ed Sheeran "
    
    //For the Table View
    @IBOutlet weak var AppTableView: UITableView!
    
    //User Search Bar
    @IBOutlet weak var Search: UITextField!
    
    
    /*----------------------------------------------------------------------------------------------------*/
                        /*View Did Load and Recieve Memory Warning Methods-*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set the delegate for our api controller to itself, so it will receive delegate function calls.
        API = APIController(delegate: self)
        
        Search.delegate = self //set delegate
        
        API.SearchItunesFor(SearchTerm)
        
        
        //Show activity meter to show something is happening
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    /*-----------------------------------------------------------------------------------------------*/
                                            /* Search Methods */
    
    /*Search Button Function, as user is typing the view is reloaded to refresh data representing the user search terms*/
    @IBAction func SearchButtomEditing(sender: AnyObject) {

        //Search term = Text in Textifield
        SearchTerm = Search.text
        viewDidLoad()
    }
    
    //Function to make keyboard dissapear when return is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true;
        
    }

    /*----------------------------------------------------------------------------------------------------*/
                                        /*UI TABLE METHODS-*/
    
    //Currently Return Same Amount of Rows as Album
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Alb.count
    }
    
    /*Use the row number to grab three pieces of information: the Album Name, the artwork url, and the price.
    We then put this information in the cell
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! UITableViewCell
        
        let album = self.Alb[indexPath.row]
        
        // Get the formatted price string for display in the subtitle
        cell.detailTextLabel?.text = album.price
        
        // Update the textLabel text to use the title from the Album model
        cell.textLabel?.text = album.title
        
        // Start by setting the cell's image to a static file
        // Without this, it will end up without an image view!
        cell.imageView?.image = UIImage(named: "Blank52")
        
        let thumbnailURLString = album.thumbnailImageURL
        
        let thumbnailURL = NSURL(string: thumbnailURLString)!
        
        // If this image is already cached, don't re-download
        if let img = imageCache[thumbnailURLString] {
            cell.imageView?.image = img
        }
        else {
            // The image isn't cached, download the img data
            // Perform this in a background thread
            let request: NSURLRequest = NSURLRequest(URL: thumbnailURL)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data)
                    // Store the image into the cache
                    self.imageCache[thumbnailURLString] = image
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView?.image = image
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }
        return cell
    }
    
    //Animation Function
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //  uses CATransform3DMakeScale() to create a transform matrix that scales down any object in x, y, and z
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        
        // Next we set the cell layer’s transform to a new scale, this time of (1,1,1
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }
    /*-------------------------------------------------------------------------------------------------*/
    
    //Function did recieve API Results.
    func didReceiveAPIResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue(), {
            self.Alb = AlbumModel.albumsWithJSON(results)
            self.AppTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    /*-------------------------------------------------------------------------------------------------*/
    /*Segue Function*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailsViewController: DetailViewController = segue.destinationViewController as? DetailViewController {
            var albumIndex = AppTableView!.indexPathForSelectedRow()!.row
            var selectedAlbum = self.Alb[albumIndex]
            detailsViewController.album = selectedAlbum
        }
    }
    
    
}

