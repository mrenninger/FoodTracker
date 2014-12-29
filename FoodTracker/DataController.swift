//
//  DataController.swift
//  FoodTracker
//
//  Created by Michael Renninger on 12/23/14.
//  Copyright (c) 2014 Michael Renninger. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let USDA_ITEM_INSTANCE_COMPLETED = "USDAItemInstanceCompleted"

class DataController {
    
    class func jsonAsUSDAIdAndNameSearchResults (json: NSDictionary) -> [(name:String, idValue: String)] {
        var usdaItemsSearchResults:[(name: String, idValue: String)] = []
        var searchResult: (name: String, idValue: String)
        
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"] as [AnyObject]
            
            for itemDict in results {
                
                if itemDict["_id"] != nil {
                    
                    if itemDict["fields"] != nil {
                        
                        let fieldsDict = itemDict["fields"] as NSDictionary
                        
                        if fieldsDict["item_name"] != nil {
                            
                            let idValue:String = itemDict["_id"]! as String
                            let name:String = fieldsDict["item_name"]! as String
                            
                            searchResult = (name: name, idValue: idValue)
                            usdaItemsSearchResults += [searchResult]
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        return usdaItemsSearchResults
    }
    
    func saveUSDAItemForId(idValue: String, json: NSDictionary) {

        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]! as [AnyObject]
            
            for itemDict in results {
                if itemDict["_id"] != nil && itemDict["_id"] as String == idValue {
                    let moc = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
                    let itemDictId = itemDict["_id"]! as String
//                    let predicate = NSPredicate(format: "idValue == %@", itemDictId)
                    var error: NSError?
                    
                    var requestForUSDAItem = NSFetchRequest(entityName: "USDAItem")
                    requestForUSDAItem.predicate = NSPredicate(format: "idValue == %@", itemDictId)
                    
                    // get all the items back
                    var items = moc?.executeFetchRequest(requestForUSDAItem, error: &error)
                    
                    /*
                    // if you don't need all the items back
                    var count = moc?.countForFetchRequest(requestForUSDAItem, error: &error)
                    */
                    
                    if items?.count != 0 {
                        // item is already saved
                        println("The item was already saved")
                        return
                    }
                    else {
                        println("Save to CoreData")
                        let entityDesc = NSEntityDescription.entityForName("USDAItem", inManagedObjectContext: moc!)
                        let usdaItem = USDAItem(entity: entityDesc!, insertIntoManagedObjectContext: moc!)
                        usdaItem.idValue = itemDict["_id"]! as String
                        usdaItem.dateAdded = NSDate()
                        
                        if itemDict["fields"] != nil {
                            let fieldsDict = itemDict["fields"]! as NSDictionary
                            
                            if fieldsDict["item_name"] != nil {
                                
                                usdaItem.name = fieldsDict["item_name"]! as String
                                
                                if fieldsDict["usda_fields"] != nil {
                                    
                                    let usdaFieldsDict = fieldsDict["usda_fields"]! as NSDictionary
                                    
                                    if usdaFieldsDict["CA"] != nil {
                                        let calciumDict = usdaFieldsDict["CA"]! as NSDictionary
                                        let calciumValue: AnyObject = calciumDict["value"]!
                                        usdaItem.calcium = "\(calciumValue)"
                                    }
                                    else {
                                        usdaItem.calcium = "0"
                                    }
                                    
                                    if usdaFieldsDict["CHOCDF"] != nil {
                                        let carbDict = usdaFieldsDict["CHOCDF"]! as NSDictionary
                                        if carbDict["value"] != nil {
                                            let carbValue: AnyObject = carbDict["value"]!
                                            usdaItem.carbohydrate = "\(carbValue)"
                                        }
                                    }
                                    else {
                                        usdaItem.carbohydrate = "0"
                                    }
                                    
                                    if usdaFieldsDict["FAT"] != nil {
                                        let fatDict = usdaFieldsDict["FAT"]! as NSDictionary
                                        if fatDict["value"] != nil {
                                            let fatValue: AnyObject = fatDict["value"]!
                                            usdaItem.fatTotal = "\(fatValue)"
                                        }
                                    }
                                    else {
                                        usdaItem.fatTotal = "0"
                                    }
                                    
                                    if usdaFieldsDict["CHOLE"] != nil {
                                        let cholesterolDict = usdaFieldsDict["CHOLE"]! as NSDictionary
                                        if cholesterolDict["value"] != nil {
                                            let cholesterolValue: AnyObject = cholesterolDict["value"]!
                                            usdaItem.cholesterol = "\(cholesterolValue)"
                                        }
                                    }
                                    else {
                                        usdaItem.cholesterol = "0"
                                    }
                                    
                                    if usdaFieldsDict["PROCNT"] != nil {
                                        let proteinDict = usdaFieldsDict["PROCNT"]! as NSDictionary
                                        if proteinDict["value"] != nil {
                                            let proteinValue: AnyObject = proteinDict["value"]!
                                            usdaItem.protein = "\(proteinValue)"
                                        }
                                    }
                                    else {
                                        usdaItem.protein = "0"
                                    }
                                    
                                    if usdaFieldsDict["SUGAR"] != nil {
                                        let sugarDict = usdaFieldsDict["SUGAR"]! as NSDictionary
                                        if sugarDict["value"] != nil {
                                            let sugarValue: AnyObject = sugarDict["value"]!
                                            usdaItem.sugar = "\(sugarValue)"
                                        }
                                    }
                                    else {
                                        usdaItem.sugar = "0"
                                    }
                                    
                                    if usdaFieldsDict["VITC"] != nil {
                                        let vitCDict = usdaFieldsDict["VITC"]! as NSDictionary
                                        if vitCDict["value"] != nil {
                                            let vitCValue: AnyObject = vitCDict["value"]!
                                            usdaItem.vitaminC = "\(vitCValue)"
                                        }
                                    }
                                    else {
                                        usdaItem.vitaminC = "0"
                                    }
                                    
                                    if usdaFieldsDict["ENERC_KCAL"] != nil {
                                        let energyDict = usdaFieldsDict["ENERC_KCAL"]! as NSDictionary
                                        if energyDict["value"] != nil {
                                            let energyValue: AnyObject = energyDict["value"]!
                                            usdaItem.energy = "\(energyValue)"
                                        }
                                    }
                                    else {
                                        usdaItem.energy = "0"
                                    }
                                    
                                    (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
                                    NSNotificationCenter.defaultCenter().postNotificationName(USDA_ITEM_INSTANCE_COMPLETED, object: usdaItem)
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}







