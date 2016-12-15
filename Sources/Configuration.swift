//
//  Configuration.swift
//  AlertNotifications
//
//  Created by Jim Avery on 12/15/16.
//
//

import Foundation
import LoggerAPI
import SwiftyJSON
import CloudFoundryEnv

public struct Configuration {
    public enum AlertNotificationError: Error {
        case IO(String)
    }
    
    let configurationFile = "cloud_config.json"
    let appEnv: AppEnv
    
    init() throws {
        let path = Configuration.getAbsolutePath(relativePath: "/\(configurationFile)", useFallback: false)
        
        guard let finalPath = path else {
            Log.warning("Could not find '\(configurationFile)'.")
            appEnv = try CloudFoundryEnv.getAppEnv()
            return
        }
        
        let url = URL(fileURLWithPath: finalPath)
        let configData = try Data(contentsOf: url)
        let configJson = JSON(data: configData)
        appEnv = try CloudFoundryEnv.getAppEnv(options: configJson)
        Log.info("Using configuration values from '\(configurationFile)'.")
    }
    
    func getAlertNotificationSDKProps() throws -> ServiceCredentials {
        if let alertCredentials = appEnv.getService(spec: "alert-notification-sdk")?.credentials {
            if let url = alertCredentials["url"].string,
            let name = alertCredentials["name"].string,
            let password = alertCredentials["password"].string {
                let credentials = ServiceCredentials(url: url, name: name, password: password)
                return credentials
            }
        }
        throw AlertNotificationError.IO("Failed to obtain database service and/or its credentials.")
    }
    
    private static func getAbsolutePath(relativePath: String, useFallback: Bool) -> String? {
        let initialPath = #file
        let components = initialPath.characters.split(separator: "/").map(String.init)
        let notLastThree = components[0..<components.count - 3]
        var filePath = "/" + notLastThree.joined(separator: "/") + relativePath
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            return filePath
        } else if useFallback {
            let currentPath = fileManager.currentDirectoryPath
            filePath = currentPath + relativePath
            if fileManager.fileExists(atPath: filePath) {
                return filePath
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
