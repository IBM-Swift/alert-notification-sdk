/**
 * Copyright IBM Corporation 2016,2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import LoggerAPI
import Configuration
import CloudFoundryEnv
import CloudFoundryConfig
import AlertNotifications

public struct Configuration {
    let configurationFile: String
    let configManager: ConfigurationManager
    
    public enum ConfigError: Error {
        case Error(String)
    }
    
    public init(withFile configFile: String) throws {
        configManager = ConfigurationManager()
        
        configurationFile = configFile
        if let path = Configuration.getAbsolutePath(relativePath: "/\(configurationFile)", useFallback: true) {
            Log.debug("Configuration file path: \(path)")
            let fileURL = URL(fileURLWithPath: path).standardized
            configManager.load(url: fileURL)
        } else {
            Log.warning("Could not find '\(configFile)'.")
        }
        
        configManager.load(.environmentVariables)
        Log.info("Using configuration values from '\(configurationFile)'.")
    }
    
    public func getAlertNotificationService(forService name: String) throws -> ServiceCredentials {
        let alertNotificationService = try configManager.getAlertNotificationService(name: name)
        return ServiceCredentials(url: alertNotificationService.url, name: alertNotificationService.id, password: alertNotificationService.password)
    }
    
    public func getCredentials(forService service: String) -> [String: Any]? {
        return configManager.getService(spec: service)?.credentials
    }
    
    public func getPort() -> Int {
        return configManager.port
    }
    
    private static func getAbsolutePath(relativePath: String, useFallback: Bool) -> String? {
        let initialPath = #file
        let fileManager = FileManager.default
        
        // We need to search for the root directory of the package
        // by searching for Package.swift.
        let components = initialPath.characters.split(separator: "/").map(String.init)
        var rootPath = initialPath
        var filePath = ""
        for index in stride(from: components.count-1, through: 0, by: -1) {
            let subArray = components[0...index]
            rootPath = "/" + subArray.joined(separator: "/")
            if fileManager.fileExists(atPath: rootPath + "/Package.swift") {
                filePath = rootPath + "/" + relativePath
                break
            }
        }
        if filePath == "" {
            return nil
        }
        
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
