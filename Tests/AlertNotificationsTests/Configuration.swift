//
//  Configuration.swift
//  AlertNotifications
//
//  Created by Jim Avery on 12/15/16.
//
//

import Foundation
import AlertNotifications
import SwiftyJSON
import LoggerAPI
import CloudFoundryEnv

public struct Configuration {
    let configurationFile = "Tests/cloud_config.json"
    let appEnv: AppEnv
    
    public enum ConfigError: Error {
        case Error(String)
    }
    
    init(withFile configFile: String) throws {
        configurationFile = configFile
        let path = Configuration.getAbsolutePath(relativePath: "/\(configurationFile)", useFallback: false)
        
        guard let finalPath = path else {
            Log.warning("Could not find '\(configFile)'.")
            appEnv = try CloudFoundryEnv.getAppEnv()
            return
        }
        
        let url = URL(fileURLWithPath: finalPath)
        let configData = try Data(contentsOf: url)
        let configJson = JSON(data: configData)
        guard configJson.type == .dictionary, let configDict = configJson.object as? [String: Any] else {
            Log.error("Invalid format for configuration file.")
            throw ConfigError.Error("Invalid format for configuration file.")
        }
        appEnv = try CloudFoundryEnv.getAppEnv(options: configDict)
        Log.info("Using configuration values from '\(configurationFile)'.")
    }
    
    func getAlertNotificationSDKProps() throws -> ServiceCredentials {
        if let alertCredentials = appEnv.getService(spec: "alert-notification-sdk")?.credentials {
            if let url = alertCredentials["url"] as? String,
                let name = alertCredentials["name"] as? String,
                let password = alertCredentials["password"] as? String {
                let credentials = ServiceCredentials(url: url, name: name, password: password)
                return credentials
            }
        }
        throw AlertNotificationError.credentialsError("Failed to obtain database service and/or its credentials.")
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
