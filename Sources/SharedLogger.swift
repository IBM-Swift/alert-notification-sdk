//
//  SharedLogger.swift
//  AlertNotifications
//
//  Created by Jim Avery on 1/3/17.
//
//

import LoggerAPI
import HeliumLogger

class SharedLogger {
    private static let sharedInstance = SharedLogger()
    
    private init() {
        Log.logger = HeliumLogger()
    }
}
