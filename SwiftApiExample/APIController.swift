//
//  APIController.swift
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

// Add a Protocol that the View Controller can Adhere Too.
protocol APIControllerProtocol
{
    func didReceiveAPIResults(results: NSArray)
}


class APIController {
    
    //Constructor to intitlise the delegate
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    
    // Non Optional Everyday Delegate
    var delegate: APIControllerProtocol
    
    //Function to Send Request and get data back in JSon
    func Get(path: String) {
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            println("Task completed")
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            var err: NSError?
            
            
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                
                if let results: NSArray = jsonResult["results"] as? NSArray {
                    self.delegate.didReceiveAPIResults(results)
                }
            }
        })
        
        // The task is just an object with all these properties set
        // In order to actually make the web request, we need to "resume"
        task.resume()
        
        
    }
    
    //Function to Search ITunes for an Album
    func SearchItunesFor(searchTerm: String) {
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music&entity=album"
            
            Get(urlPath) //Call Get Function with urlPath as Path
        }
    }
    
    //Takes ID and Uses GET function to get track information
    func lookupAlbum(collectionId: Int) {
        Get("https://itunes.apple.com/lookup?id=\(collectionId)&entity=song")
    }
    
}