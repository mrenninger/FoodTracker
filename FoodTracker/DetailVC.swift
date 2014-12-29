//
//  DetailVC.swift
//  FoodTracker
//
//  Created by Michael Renninger on 12/23/14.
//  Copyright (c) 2014 Michael Renninger. All rights reserved.
//

import UIKit
import HealthKit

class DetailVC: UIViewController {

    var usdaItem: USDAItem?
    
    @IBOutlet weak var textView: UITextView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: USDA_ITEM_INSTANCE_COMPLETED, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        requestHealthStoreAuthorization()
        
        if usdaItem != nil {
            textView.attributedText = createAttributedString(usdaItem!)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func eatItBtnPressed(sender: UIBarButtonItem) {
        saveFoodItem(self.usdaItem!)
    }
    
    func usdaItemDidComplete(notification: NSNotification) {
        println("usdaItemDidComplete in DetailVC")
        usdaItem = notification.object as? USDAItem
        
        if self.isViewLoaded() && self.view.window != nil {
            textView.attributedText = createAttributedString(usdaItem!)
        }
    }
    
    func createAttributedString (item:USDAItem) -> NSAttributedString {
        var itemAttrStr = NSMutableAttributedString()
        
        var centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .Center
        centeredParagraphStyle.lineSpacing = 10.0
        
        var leftAllignedParagraphStyle = NSMutableParagraphStyle()
        leftAllignedParagraphStyle.alignment = NSTextAlignment.Left
        leftAllignedParagraphStyle.lineSpacing = 20.0
        
        var titleAttrDict = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(22.0),
            NSParagraphStyleAttributeName: centeredParagraphStyle
        ]
        
        var styleFirstWordAttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont.boldSystemFontOfSize(18.0),
            NSParagraphStyleAttributeName : leftAllignedParagraphStyle
        ]
        
        var style1AttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.darkGrayColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(18.0),
            NSParagraphStyleAttributeName : leftAllignedParagraphStyle
        ]
        
        var style2AttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.lightGrayColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(18.0),
            NSParagraphStyleAttributeName : leftAllignedParagraphStyle
        ]
        
        // Title
        let titleStr = NSAttributedString(string: "\(usdaItem!.name)\n", attributes: titleAttrDict)
        itemAttrStr.appendAttributedString(titleStr)
        
        // Calcium
        let calciumTitleString = NSAttributedString(string: "Calcium ", attributes: styleFirstWordAttributesDictionary)
        let calciumBodyString = NSAttributedString(string: "\(usdaItem!.calcium)% \n", attributes: style1AttributesDictionary)
        itemAttrStr.appendAttributedString(calciumTitleString)
        itemAttrStr.appendAttributedString(calciumBodyString)
        
        // Carbohydrate
        let carbohydrateTitleString = NSAttributedString(string: "Carbohydrate ", attributes: styleFirstWordAttributesDictionary)
        let carbohydrateBodyString = NSAttributedString(string: "\(usdaItem!.carbohydrate)% \n", attributes: style2AttributesDictionary)
        itemAttrStr.appendAttributedString(carbohydrateTitleString)
        itemAttrStr.appendAttributedString(carbohydrateBodyString)
        
        // Cholesterol
        let cholesterolTitleString = NSAttributedString(string: "Cholesterol ", attributes: styleFirstWordAttributesDictionary)
        let cholesterolBodyString = NSAttributedString(string: "\(usdaItem!.cholesterol)% \n", attributes: style1AttributesDictionary)
        itemAttrStr.appendAttributedString(cholesterolTitleString)
        itemAttrStr.appendAttributedString(cholesterolBodyString)
        
        // Energy
        let energyTitleString = NSAttributedString(string: "Energy ", attributes: styleFirstWordAttributesDictionary)
        let energyBodyString = NSAttributedString(string: "\(usdaItem!.energy)% \n", attributes: style2AttributesDictionary)
        itemAttrStr.appendAttributedString(energyTitleString)
        itemAttrStr.appendAttributedString(energyBodyString)
        
        // Fat Total
        let fatTotalTitleString = NSAttributedString(string: "FatTotal ", attributes: styleFirstWordAttributesDictionary)
        let fatTotalBodyString = NSAttributedString(string: "\(usdaItem!.fatTotal)% \n", attributes: style1AttributesDictionary)
        itemAttrStr.appendAttributedString(fatTotalTitleString)
        itemAttrStr.appendAttributedString(fatTotalBodyString)
        
        // Protein
        let proteinTitleString = NSAttributedString(string: "Protein ", attributes: styleFirstWordAttributesDictionary)
        let proteinBodyString = NSAttributedString(string: "\(usdaItem!.protein)% \n", attributes: style2AttributesDictionary)
        itemAttrStr.appendAttributedString(proteinTitleString)
        itemAttrStr.appendAttributedString(proteinBodyString)
        
        // Sugar
        let sugarTitleString = NSAttributedString(string: "Sugar ", attributes: styleFirstWordAttributesDictionary)
        let sugarBodyString = NSAttributedString(string: "\(usdaItem!.sugar)% \n", attributes: style1AttributesDictionary)
        itemAttrStr.appendAttributedString(sugarTitleString)
        itemAttrStr.appendAttributedString(sugarBodyString)
        
        // Vitamin C
        let vitaminCTitleString = NSAttributedString(string: "Vitamin C ", attributes: styleFirstWordAttributesDictionary)
        let vitaminCBodyString = NSAttributedString(string: "\(usdaItem!.vitaminC)% \n", attributes: style2AttributesDictionary)
        itemAttrStr.appendAttributedString(vitaminCTitleString)
        itemAttrStr.appendAttributedString(vitaminCBodyString)
        
        return itemAttrStr
    }
    
    func requestHealthStoreAuthorization() {
        let writeDataTypes = [
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCalcium),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCholesterol),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryProtein),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySugar),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminC)
        ]
        
        let readDataTypes = [
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCalcium),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCholesterol),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryProtein),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySugar),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminC)
        ]
        
        var store: HealthStoreConstant = HealthStoreConstant()
        store.healthStore.requestAuthorizationToShareTypes(NSSet(array: writeDataTypes), readTypes: NSSet(array: readDataTypes), completion: { (success, error) -> Void in
            if success {
                println("User completed authorization request.")
            }
            else {
                println("User canceled the request \(error)")
            }
        })
    }
    
    func saveFoodItem (foodItem: USDAItem) {
        if HKHealthStore.isHealthDataAvailable() {
            let timeFoodWasEntered = NSDate()
            let foodMetaData = [
                HKMetadataKeyFoodType : foodItem.name,
                "HKBrandName" : "USDAItem",
                "HKFoodTypeID" : foodItem.idValue
            ]
            
            let energyUnit = HKQuantity(unit: .kilocalorieUnit(), doubleValue: (foodItem.energy as NSString).doubleValue) // HKUnit.kilocalorieUnit

            let calories = HKQuantitySample(type: .quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed), quantity: energyUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData) //HKQuantityType.quantityTypeForIdentifier(
            
            let calciumUnit = HKQuantity(unit: .gramUnitWithMetricPrefix(.Milli), doubleValue: (foodItem.calcium as NSString).doubleValue)
            let calcium = HKQuantitySample(type: .quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCalcium), quantity: calciumUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            let carbohydrateUnit = HKQuantity(unit: .gramUnit(), doubleValue: (foodItem.carbohydrate as NSString).doubleValue)
            let carbohydrates = HKQuantitySample(type: .quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates), quantity: carbohydrateUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)

            let cholesterolUnit = HKQuantity(unit: .gramUnitWithMetricPrefix(.Milli), doubleValue: (foodItem.cholesterol as NSString).doubleValue)
            let cholesterol = HKQuantitySample(type: .quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCholesterol), quantity: cholesterolUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            let fatTotalUnit = HKQuantity(unit: .gramUnit(), doubleValue: (foodItem.fatTotal as NSString).doubleValue)
            let fatTotal = HKQuantitySample(type: .quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal), quantity: fatTotalUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            let proteinUnit = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: (foodItem.protein as NSString).doubleValue)
            let protein = HKQuantitySample(type: .quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryProtein), quantity: proteinUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
        
            let sugarUnit = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: (foodItem.sugar as NSString).doubleValue)
            let sugar = HKQuantitySample(type: .quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySugar), quantity: sugarUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            let vitaminCUnit = HKQuantity(unit: HKUnit.gramUnitWithMetricPrefix(.Milli), doubleValue: (foodItem.vitaminC as NSString).doubleValue)
            let vitaminC = HKQuantitySample(type: .quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminC), quantity: vitaminCUnit, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, metadata: foodMetaData)
            
            let foodDataSet = NSSet(array: [calories, calcium, carbohydrates, cholesterol, fatTotal, protein, sugar, vitaminC])
            let foodCoorelation = HKCorrelation(type: .correlationTypeForIdentifier(HKCorrelationTypeIdentifierFood), startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, objects: foodDataSet, metadata : foodMetaData) // HKCorrelationType.correlationTypeForIdentifier
            
            var store:HealthStoreConstant = HealthStoreConstant()
            store.healthStore.saveObject(foodCoorelation, withCompletion: { (success, error) -> Void in
                if success {
                    println("saved successfully")
                }
                else {
                    println("Error Occured: \(error)")
                }
            })
        }
    }
}





