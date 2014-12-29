//
//  ViewController.swift
//  FoodTracker
//
//  Created by Michael Renninger on 12/23/14.
//  Copyright (c) 2014 Michael Renninger. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    
    var suggestedSearchFoods:[String] = []
    var filteredSuggestedSearchFoods:[String] = []
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    var apiSearchForFoods: [(name:String, idValue:String)] = []
    var favoritedUSDAItems:[USDAItem] = []
    var filteredFavoritedUSDAItems:[USDAItem] = []
    
    let APP_ID = "71d8d108"
    let APP_KEY = "4f9f449d3ecf38eb82a341778ffb0c03"
    
    var jsonResponse: NSDictionary!
    
    var dataController = DataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.frame = CGRectMake(searchController.searchBar.frame.origin.x, searchController.searchBar.frame.origin.y, searchController.searchBar.frame.size.width, 44.0)
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.delegate = self
        searchController.definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = scopeButtonTitles
        
        suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicen breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: USDA_ITEM_INSTANCE_COMPLETED, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailVC" {
            if sender != nil {
                var detailVC = segue.destinationViewController as DetailVC
                detailVC.usdaItem = sender as? USDAItem
            }
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Setup CoreData
    func requestFavoritedUSDAItems () {
        let req = NSFetchRequest(entityName: "USDAItem")
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let moc = appDelegate.managedObjectContext
        favoritedUSDAItems = moc?.executeFetchRequest(req, error: nil) as [USDAItem]
    }
    
    // MARK: - NSNotificationCenter
    func usdaItemDidComplete (notification:NSNotification) {
        println("usdaItemDidComplete in ViewController")
        requestFavoritedUSDAItems()
        let selectedScopeBtnIndex = searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeBtnIndex == 2 {
            tableView.reloadData()
        }
    }
}

// Mark: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("ViewController::tableView.didSelectRowAtIndexPath")
        let selectedScopeBtnIndex = searchController.searchBar.selectedScopeButtonIndex
        println("\tselectedScopeBtnIndex: \(selectedScopeBtnIndex)")
        if selectedScopeBtnIndex == 0 {
            var searchFoodName:String = searchController.active ? filteredSuggestedSearchFoods[indexPath.row] : suggestedSearchFoods[indexPath.row]
            
//            var searchFoodName:String
//            if searchController.active {
//                searchFoodName = filteredSuggestedSearchFoods[indexPath.row]
//            }
//            else {
//                searchFoodName = suggestedSearchFoods[indexPath.row]
//            }
            
            searchController.searchBar.selectedScopeButtonIndex = 1
            makeRequest(searchFoodName)
        }
        else if selectedScopeBtnIndex == 1 {
            performSegueWithIdentifier("showDetailVC", sender: nil)
            let idValue = apiSearchForFoods[indexPath.row].idValue
            dataController.saveUSDAItemForId(idValue, json: jsonResponse)
        }
        else if selectedScopeBtnIndex == 2 {
            let usdaItem = searchController.active ? filteredFavoritedUSDAItems[indexPath.row] : favoritedUSDAItems[indexPath.row]
//            println("\t\tsearchController.active: \(searchController.active)")
//            println("\t\tsearchController.indexPath.row: \(indexPath.row)")
//            println("\t\tsearchController.filteredFavoritedUSDAItems: \(filteredFavoritedUSDAItems.count)")
//            println("\t\tsearchController.filteredFavoritedUSDAItems[indexPath.row]: \(filteredFavoritedUSDAItems[indexPath.row].name)")
//            println("\t\tsearchController.favoritedUSDAItems: \(favoritedUSDAItems.count)")
//            println("\t\tsearchController.favoritedUSDAItems[indexPath.row]: \(favoritedUSDAItems[indexPath.row].name)")
//            println("\t\tusdaItem: \(usdaItem)")
            performSegueWithIdentifier("showDetailVC", sender: usdaItem)
//            if searchController.active {
//                let usdaItem = filteredFavoritedUSDAItems[indexPath.row]
//                performSegueWithIdentifier("showDetailVC", sender: usdaItem)
//            }
//            else {
//                let usdaItem = favoritedUSDAItems[indexPath.row]
//                performSegueWithIdentifier("showDetailVC", sender: usdaItem)
//            }
        }
    }
}

// Mark: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        var foodName: String
        let selectedScopeBtnIndex = searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeBtnIndex == 0 {
            foodName = searchController.active ? filteredSuggestedSearchFoods[indexPath.row] : suggestedSearchFoods[indexPath.row]
        }
        else if selectedScopeBtnIndex == 1 {
            foodName = apiSearchForFoods[indexPath.row].name
        }
        else {
            foodName = searchController.active ? filteredFavoritedUSDAItems[indexPath.row].name : favoritedUSDAItems[indexPath.row].name
        }
        
        cell.textLabel?.text = foodName
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedScopeBtnIndex = searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeBtnIndex == 0 {
            return searchController.active ? filteredSuggestedSearchFoods.count : suggestedSearchFoods.count
        }
        else if selectedScopeBtnIndex == 1 {
            return apiSearchForFoods.count
        }
        else {
            return searchController.active ? filteredFavoritedUSDAItems.count : favoritedUSDAItems.count
        }
    }
}

// Mark: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchController.searchBar.selectedScopeButtonIndex = 1
        makeRequest(searchBar.text)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 2 {
            requestFavoritedUSDAItems()
        }
        tableView.reloadData()
    }
}

// Mark: - UISearchControllerDelegate
extension ViewController: UISearchControllerDelegate {
    
}

// Mark: - UISearchControllerDelegate
//extension ViewController: UISearchDisplayDelegate {
//    func searchDisplayControllerDidBeginSearch(controller: UISearchDisplayController) {
//        searchController.searchBar.becomeFirstResponder()
//    }
//}

// Mark: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let str = searchController.searchBar.text
        let scopeIndex = searchController.searchBar.selectedScopeButtonIndex
        filterContentForSearch(str, scope: scopeIndex)
        tableView.reloadData()
    }
    
    func filterContentForSearch (searchText:String, scope: Int) {
        if scope == 0 {
            filteredSuggestedSearchFoods = suggestedSearchFoods.filter({ (food:String) -> Bool in
                var foodMatch = food.rangeOfString(searchText)
                return foodMatch != nil
            })
        }
        else if scope == 2 {
            filteredFavoritedUSDAItems = favoritedUSDAItems.filter({ (item:USDAItem) -> Bool in
                var stringMatch = item.name.rangeOfString(searchText)
                return stringMatch != nil
            })
        }
    }
    
    func makeRequest (str: String) {
        
        let session = NSURLSession.sharedSession()
        var params = [
            "appId": APP_ID,
            "appKey": APP_KEY,
            "fields": ["item_name", "brand_name", "keywords", "usda_fields"],
            "limit": "50",
            "query": str,
            "filters": ["exists": ["usda_fields": true]]
        ]
        var error: NSError?
        
        let req = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search/")!)
        req.HTTPMethod = "POST"
        req.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(req, completionHandler: { (data, response, err) -> Void in
//            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println(strData)
            var convertedErr: NSError?
            var JSONDict = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &convertedErr) as? NSDictionary
            //println(JSONDict)
            
            if convertedErr != nil {
                println(convertedErr!.localizedDescription)
                let errStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error parsing \(errStr)")
            }
            else {
                if JSONDict != nil {
                    self.jsonResponse = JSONDict!
                    self.apiSearchForFoods = DataController.jsonAsUSDAIdAndNameSearchResults(JSONDict!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
                else {
                    let errStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON \(errStr)")
                }
            }
        })
        
        task.resume()
        
        // how to make a GET request
//        let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/\(str)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(APP_ID)&appKey=\(APP_KEY)")
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
//            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println(strData)
//            println(response)
//        })
//        task.resume()
    }
}
