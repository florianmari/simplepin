//
//  Network.swift
//  simplepin
//
//  Created by Mathias Lindholm on 29.3.2016.
//  Copyright © 2016 Mathias Lindholm. All rights reserved.
//

import Foundation

struct Network {
    static func fetchAllPosts(completion: ([BookmarkItem]) -> Void) -> NSURLSessionTask? {
        let defaults = NSUserDefaults.standardUserDefaults()
        let userToken = defaults.stringForKey("userToken")! as String

        guard let url = NSURL(string: "https://api.pinboard.in/v1/posts/all?auth_token=\(userToken)&format=json") else {
            completion([])
            return nil
        }

        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, httpResponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                guard let data = data where error == nil else {
                    completion([])
                    return
                }
                let optionalBookmarks = parseJSONData(data)
                completion(optionalBookmarks)
            })
        }

        task.resume()
        return task
    }

    static func parseJSONData(data: NSData) -> [BookmarkItem] {
        var bookmarks = [BookmarkItem]()
        do {
            if let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [AnyObject] {
                for item in jsonObject {
                    guard let bookmarkDict = item as? [String: AnyObject],
                        let bookmark = BookmarkItem(json: bookmarkDict)
                        else { continue }
                    bookmarks.append(bookmark)
                }
            }
        } catch {
            debugPrint("Error parsing JSON")
        }
        return bookmarks
    }

    static func fetchApiToken(username: String, _ password: String, completion: (String?) -> Void) -> NSURLSessionTask? {
        guard let url = NSURL(string: "https://\(username):\(password)@api.pinboard.in/v1/user/api_token/?format=json") else {
            completion(nil)
            return nil
        }
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, httpResponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                guard let data = data where error == nil else {
                    completion(nil)
                    return
                }
                let userToken = parseAPIToken(data)
                completion(userToken)
            })
        }

        task.resume()
        return task
    }

    static func parseAPIToken(data: NSData) -> String? {
        if let jsonObject = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: AnyObject] {
            return jsonObject["result"] as? String
        }
        return nil
    }
}