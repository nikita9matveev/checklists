//
//  DataModel.swift
//  CheckLists
//
//  Created by yuheni on 01.12.17.
//  Copyright © 2017 yauheni. All rights reserved.
//

import Foundation

class DataModel {
    
    var lists = [CheckList]()
    
    init() {
        loadCheckLists()
        registerDefaults()
        handleFirstTime()
    }
    
    var indexOfSelectedCheckList: Int {
        get {
            return UserDefaults.standard.integer(forKey: "CheckListIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CheckListIndex")
        }
    }
    
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return itemID
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory,in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func saveCheckLists() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(lists, forKey: "CheckLists")
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
    }
    
    func loadCheckLists() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            lists = unarchiver.decodeObject(forKey: "CheckLists") as! [CheckList]
            unarchiver.finishDecoding()
            sortCheckLists()
        }
    }
    
    func registerDefaults() {
        let dictionary: [String: Any] = [ "CheckListIndex": -1, "FirstTime": true, "ChecklistItemID": 0  ]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        if firstTime {
            let checklist = CheckList(name: "List")
            lists.append(checklist)
            indexOfSelectedCheckList = 0
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
    }
    
    func sortCheckLists() {
        lists.sort(by: { checklist1, checklist2 in
            return checklist1.name.localizedStandardCompare(checklist2.name) == .orderedAscending })
    }
}
