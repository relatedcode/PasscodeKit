//
//  PasscodeInterval.swift
//  app
//
//  Created by StephenFang on 2022/7/16.
//  Copyright © 2022 KZ. All rights reserved.
//

import Foundation

enum PasscodeInterval: Double, CaseIterable {
    case immediately  = 0.0
    case oneMinute    = 1.0
    case fiveMinutes  = 5.0
    case tenMinutes   = 10.0
    case halfAnHour   = 30.0
    case anHour       = 60.0
    
    var localizedDescription: String {
        if self == .immediately {
            return PasscodeKit.vefifyPasscodeImmediately
        } else if self == .anHour {
            return PasscodeKit.vefifyPasscodeAfterOneHour
        } else {
            return String(format: PasscodeKit.vefifyPasscodeAfterMinutes, rawValue)
        }
    }
}
