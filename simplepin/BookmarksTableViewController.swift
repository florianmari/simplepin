//
//  BookmarksTableViewController.swift
//  simplepin
//
//  Created by Mathias Lindholm on 29.2.2016.
//  Copyright © 2016 Mathias Lindholm. All rights reserved.
//

import UIKit

struct BookmarkItem {
    let title: String
    let description: String
    let date: NSDate
    let link: NSURL
    let tags: String

    init?(json: [String: AnyObject]) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-DD'T'HH:mm:SSZ"
        let dateString = json["time"] as? String
        let linkString = json["href"] as? String

        guard let title = json["description"] as? String,
            let description = json["extended"] as? String,
            let date = formatter.dateFromString(dateString!),
            let link = NSURL(string: linkString!),
            let tags = json["tags"] as? String else {
                return nil
        }
        self.title = title
        self.description = description
        self.date = date
        self.link = link
        self.tags = tags
    }
}

struct Network {

    static func fetchAllPosts(completion: ([BookmarkItem]) -> Void) -> NSURLSessionTask? {
        guard let url = NSURL(string: "https://api.pinboard.in/v1/posts/all?auth_token=xxx:yyy&format=json") else {
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
}

class BookmarksTableViewController: UITableViewController, NSXMLParserDelegate {
    var bookmarks = [BookmarkItem]()
    var fetchAllPostsTask: NSURLSessionTask?

    @IBOutlet var tableData: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchAllPostsTask = Network.fetchAllPosts() { [weak self] bookmarks in
            self?.bookmarks = bookmarks
            self?.tableData.reloadData()
        }

        tableView.estimatedRowHeight = 96.0
        tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        let bookmark = bookmarks[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("BookmarkCell", forIndexPath: indexPath) as! BookmarkTableViewCell

        cell.titleLabel.text = bookmark.title
        if bookmark.description.isEmpty {
            cell.descriptionLabel.hidden = true
        } else {
            cell.descriptionLabel.hidden = false
            cell.descriptionLabel.text = bookmark.description
        }
        cell.dateLabel.text = formatter.stringFromDate(bookmark.date)
        if bookmark.tags.isEmpty {
            cell.tagLabel.hidden = true
        } else {
            cell.tagLabel.hidden = false
            cell.tagLabel.text = "#"+bookmark.tags
            // TODO: display each tag as own label
        }

        return cell
    }


    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
