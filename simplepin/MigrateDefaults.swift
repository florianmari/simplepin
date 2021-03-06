//
//  MigrateDefaults.swift
//  simplepin
//
//  Created by Mathias Lindholm on 8.7.2016.
//  Copyright © 2016 Mathias Lindholm. All rights reserved.
//

import Foundation

func migrateUserDefaultsToAppGroups() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let groupDefaults = NSUserDefaults(suiteName: "group.ml.simplepin")
    let didMigrateToAppGroups = "DidMigrateToAppGroups"

    if let groupDefaults = groupDefaults {
        if !groupDefaults.boolForKey(didMigrateToAppGroups) {
            for key in userDefaults.dictionaryRepresentation().keys {
                groupDefaults.setObject(userDefaults.dictionaryRepresentation()[key], forKey: key)
            }
            groupDefaults.setBool(true, forKey: didMigrateToAppGroups)
        }
    }
}